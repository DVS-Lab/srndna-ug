#!/usr/bin/env python3
"""Audit ultimatum-game timing and missed trials from canonical BIDS events.

The BIDS converter labels misses only as ``missed_trial``. This script recovers
their partner from the enclosing block instead of incorrectly treating every
miss as a computer trial. It writes compact, deidentified source-data tables
and never changes BIDS inputs.
"""

from __future__ import annotations

import argparse
import csv
import math
import re
import statistics
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path


TRIAL_RE = re.compile(
    r"^(?:event_(?:accept|reject)_(?:computer|ingroup|outgroup)(?:_(?:un)?fair)?|missed_trial)$"
)
PARTNERS = ("computer", "ingroup", "outgroup")


@dataclass(frozen=True)
class Trial:
    participant: str
    run: str
    onset: float
    duration: float
    partner: str
    missed: int
    response_time_raw: float | None
    offer: float | None
    block: str


def read_rows(path: Path, delimiter: str = "\t") -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8-sig") as stream:
        return list(csv.DictReader(stream, delimiter=delimiter))


def number(value: str) -> float | None:
    if value.strip().lower() in {"", "n/a", "na", "nan"}:
        return None
    return float(value)


def partner_from_block(block: str) -> str:
    matches = [partner for partner in PARTNERS if partner in block.lower()]
    if len(matches) != 1:
        raise ValueError(f"cannot identify exactly one partner from block {block!r}")
    return matches[0]


def parse_event_file(path: Path, participant: str, run: str) -> tuple[list[Trial], int]:
    rows = read_rows(path)
    blocks = sorted(
        (float(row["onset"]), row["trial_type"])
        for row in rows
        if row["trial_type"].startswith("block_")
    )
    if not blocks:
        raise ValueError(f"no block rows in {path}")

    trials: list[Trial] = []
    for row in rows:
        trial_type = row["trial_type"]
        if not TRIAL_RE.match(trial_type):
            continue
        onset = float(row["onset"])
        preceding = [(start, label) for start, label in blocks if start <= onset]
        if not preceding:
            raise ValueError(f"trial precedes every block in {path}: onset {onset}")
        block = max(preceding)[1]
        partner = partner_from_block(block)
        if trial_type != "missed_trial" and partner not in trial_type:
            raise ValueError(f"trial/block partner mismatch in {path}: {trial_type}, {block}")
        trials.append(
            Trial(
                participant=participant,
                run=run,
                onset=onset,
                duration=float(row["duration"]),
                partner=partner,
                missed=int(trial_type == "missed_trial"),
                response_time_raw=number(row.get("response_time", "")),
                offer=number(row.get("Offer", "")),
                block=block,
            )
        )
    return sorted(trials, key=lambda trial: trial.onset), len(blocks)


def participant_sample(path: Path) -> dict[str, str]:
    sample: dict[str, str] = {}
    for row in read_rows(path, delimiter=","):
        participant = (row.get("subjID") or row.get("participant_id") or "").strip()
        if not participant:
            raise ValueError(f"participant identifier missing in {path}")
        if float(row["younger"]) == 1:
            group = "younger"
        elif float(row["older"]) == 1:
            group = "older"
        else:
            raise ValueError(f"age group is not one-hot for {participant}")
        sample[participant] = group
    return sample


def write_tsv(path: Path, fieldnames: list[str], rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames, delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def mean_sd(values: list[float]) -> tuple[float, float]:
    return statistics.mean(values), statistics.stdev(values) if len(values) > 1 else math.nan


def audit(bids_root: Path, sample_path: Path, output_dir: Path) -> dict[str, object]:
    sample = participant_sample(sample_path)
    trials: list[Trial] = []
    run_records: list[tuple[str, str, int, int]] = []
    for participant in sample:
        paths = sorted((bids_root / participant / "func").glob(f"{participant}_task-ultimatum_run-*_events.tsv"))
        if not paths:
            raise FileNotFoundError(f"no ultimatum event files for {participant}")
        for path in paths:
            match = re.search(r"_run-([^_]+)_events\.tsv$", path.name)
            if not match:
                raise ValueError(f"cannot parse run from {path}")
            run = match.group(1)
            parsed, blocks = parse_event_file(path, participant, run)
            trials.extend(parsed)
            run_records.append((participant, run, len(parsed), blocks))

    by_subject: dict[str, Counter[str]] = defaultdict(Counter)
    trial_rows: list[dict[str, object]] = []
    within_gaps: list[float] = []
    between_gaps: list[float] = []
    by_run: dict[tuple[str, str], list[Trial]] = defaultdict(list)
    for trial in trials:
        by_subject[trial.participant][trial.partner] += trial.missed
        by_run[(trial.participant, trial.run)].append(trial)
        trial_rows.append(
            {
                "participant": trial.participant,
                "age_group": sample[trial.participant],
                "run": trial.run,
                "onset": f"{trial.onset:.6f}",
                "duration": f"{trial.duration:.6f}",
                "partner": trial.partner,
                "missed": trial.missed,
                "response_time_raw": "" if trial.response_time_raw is None else f"{trial.response_time_raw:.6f}",
                "response_selection_time": "" if trial.response_time_raw is None else f"{trial.response_time_raw - 1:.6f}",
                "offer": "" if trial.offer is None else f"{trial.offer:g}",
                "block": trial.block,
            }
        )
    for run_trials in by_run.values():
        for current, following in zip(run_trials, run_trials[1:]):
            gap = following.onset - current.onset - current.duration
            (within_gaps if current.block == following.block else between_gaps).append(gap)

    participant_rows: list[dict[str, object]] = []
    for participant, group in sample.items():
        counts = by_subject[participant]
        participant_rows.append(
            {
                "participant": participant,
                "age_group": group,
                "missed_computer": counts["computer"],
                "missed_similar": counts["ingroup"],
                "missed_dissimilar": counts["outgroup"],
                "missed_total": sum(counts.values()),
            }
        )

    duration_mean, duration_sd = mean_sd([trial.duration for trial in trials])
    within_mean, within_sd = mean_sd(within_gaps)
    summary_rows = [
        {"metric": "participants", "value": len(sample), "detail": "analysis sample"},
        {"metric": "runs", "value": len(run_records), "detail": "ultimatum event files"},
        {"metric": "trials", "value": len(trials), "detail": "one row per task trial"},
        {"metric": "missed_trials", "value": sum(trial.missed for trial in trials), "detail": "all partners"},
        {"metric": "trial_duration_mean_seconds", "value": f"{duration_mean:.9f}", "detail": f"SD={duration_sd:.9f}"},
        {"metric": "within_block_gap_mean_seconds", "value": f"{within_mean:.9f}", "detail": f"SD={within_sd:.9f}"},
        {
            "metric": "between_block_gap_counts_rounded",
            "value": ";".join(f"{gap:g}:{count}" for gap, count in sorted(Counter(round(value) for value in between_gaps).items())),
            "detail": "gap seconds:count",
        },
    ]

    write_tsv(output_dir / "task_trial_source_data.tsv", list(trial_rows[0]), trial_rows)
    write_tsv(output_dir / "missed_trials_by_participant.tsv", list(participant_rows[0]), participant_rows)
    write_tsv(output_dir / "task_event_summary.tsv", ["metric", "value", "detail"], summary_rows)
    return {"participants": len(sample), "runs": len(run_records), "trials": len(trials), "misses": sum(t.missed for t in trials)}


def parse_args() -> argparse.Namespace:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bids-root", type=Path, default=root / "bids")
    parser.add_argument("--sample", type=Path, default=root / "behavioral_analyses" / "data" / "participant_L3_47.csv")
    parser.add_argument("--output-dir", type=Path, default=root / "results" / "reviewer" / "tables")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    result = audit(args.bids_root, args.sample, args.output_dir)
    print("PASS: " + ", ".join(f"{key}={value}" for key, value in result.items()))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
