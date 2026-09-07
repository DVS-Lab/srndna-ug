#!/usr/bin/env python3
"""Move clearly generated large artifacts to a verified local archive.

The operation is deliberately narrower than a history rewrite. It inventories
and hashes every selected file, writes a tracked provenance manifest, and then
moves whole directories on the same filesystem. The archive must not already
exist, and no destination is overwritten.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import shutil
import subprocess
from datetime import date
from pathlib import Path


FIXED_DIRECTORIES = (
    "behavioral_analyses/fits",
    "behavioral_analyses/figures/z_archive",
    "behavioral_analyses/figures/SANS_archive",
    "behavioral_analyses/figures/computer_fit",
    "behavioral_analyses/figures/human_fit",
    "behavioral_analyses/figures/ingroup_fit",
    "behavioral_analyses/figures/outgroup_fit",
    "behavioral_analyses/figures/mean",
    "behavioral_analyses/figures/median",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def tracked_blobs(root: Path) -> dict[str, str]:
    result = subprocess.run(
        ["git", "ls-files", "-s", "-z"], cwd=root, check=True, capture_output=True
    ).stdout
    blobs: dict[str, str] = {}
    for record in result.split(b"\0"):
        if not record:
            continue
        metadata, raw_path = record.split(b"\t", 1)
        fields = metadata.decode().split()
        blobs[raw_path.decode()] = fields[1]
    return blobs


def selected_directories(root: Path) -> list[Path]:
    directories = [root / relative for relative in FIXED_DIRECTORIES]
    directories.extend(sorted((root / "behavioral_analyses" / "figures").glob("ugRL_*")))
    unique = sorted({path.resolve() for path in directories if path.is_dir()})
    return [Path(path) for path in unique]


def inventory(root: Path, directories: list[Path]) -> list[dict[str, object]]:
    blobs = tracked_blobs(root)
    rows: list[dict[str, object]] = []
    for directory in directories:
        for path in sorted(item for item in directory.rglob("*") if item.is_file()):
            relative = str(path.relative_to(root))
            rows.append(
                {
                    "source_path": relative,
                    "archive_relative_path": relative,
                    "size_bytes": path.stat().st_size,
                    "sha256": sha256(path),
                    "git_blob": blobs.get(relative, "UNTRACKED"),
                    "archive_date": date.today().isoformat(),
                }
            )
    return rows


def write_manifest(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def parse_args() -> argparse.Namespace:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=root)
    parser.add_argument("--archive-root", type=Path, required=True)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--apply", action="store_true", help="perform moves after writing the manifest")
    mode.add_argument("--verify", action="store_true", help="verify an existing archive against the tracked manifest")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = args.root.resolve()
    archive_root = args.archive_root.resolve()
    manifest = root / "logs" / "records" / "generated-artifact-archive.tsv"
    if args.verify:
        if not archive_root.is_dir() or not manifest.is_file():
            raise FileNotFoundError("archive directory and tracked manifest are required for verification")
        with manifest.open(newline="", encoding="utf-8") as stream:
            rows = list(csv.DictReader(stream, delimiter="\t"))
        failures: list[str] = []
        for row in rows:
            path = archive_root / row["archive_relative_path"]
            if not path.is_file():
                failures.append(f"missing: {row['archive_relative_path']}")
            elif path.stat().st_size != int(row["size_bytes"]):
                failures.append(f"size mismatch: {row['archive_relative_path']}")
            elif sha256(path) != row["sha256"]:
                failures.append(f"checksum mismatch: {row['archive_relative_path']}")
        if failures:
            raise RuntimeError("archive verification failed:\n" + "\n".join(failures[:20]))
        print(f"PASS: verified {len(rows)} archived files")
        return 0
    if archive_root.exists():
        raise FileExistsError(f"archive destination already exists: {archive_root}")
    if root == archive_root or root in archive_root.parents:
        raise ValueError("archive must be outside the repository")
    directories = selected_directories(root)
    if not directories:
        raise FileNotFoundError("no selected generated-artifact directories exist")
    rows = inventory(root, directories)
    if not rows:
        raise FileNotFoundError("selected directories contain no files")
    total = sum(int(row["size_bytes"]) for row in rows)
    print(f"Inventory: {len(rows)} files, {total / 1024**3:.2f} GiB, {len(directories)} directories")
    if not args.apply:
        print("DRY RUN: add --apply to write the manifest and move directories")
        return 0

    archive_root.mkdir(parents=True, exist_ok=False)
    write_manifest(manifest, rows)
    shutil.copy2(manifest, archive_root / "generated-artifact-archive.tsv")
    (archive_root / "README.txt").write_text(
        "Local archive of generated SRNDNA-UG artifacts. Restore each archive_relative_path "
        "to the repository root if needed. SHA-256 and original Git blob IDs are in the manifest.\n",
        encoding="utf-8",
    )
    for source in directories:
        relative = source.relative_to(root)
        destination = archive_root / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            raise FileExistsError(destination)
        source.rename(destination)
    print(f"PASS: moved verified artifacts to {archive_root}")
    print(f"Tracked manifest: {manifest.relative_to(root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
