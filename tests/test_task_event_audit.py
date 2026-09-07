from __future__ import annotations

import csv
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "code"))

from audit_task_events import audit, parse_event_file, partner_from_block


class TaskEventAuditTests(unittest.TestCase):
    def test_partner_from_block_is_strict(self) -> None:
        self.assertEqual(partner_from_block("block_ingroup_fair"), "ingroup")
        with self.assertRaises(ValueError):
            partner_from_block("block_unknown")

    def test_miss_recovers_partner_from_enclosing_block(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "sub-999_task-ultimatum_run-01_events.tsv"
            path.write_text(
                "onset\tduration\ttrial_type\tresponse_time\tOffer\tIsFairBlock\n"
                "1\t10\tblock_outgroup_fair\tn/a\tn/a\tn/a\n"
                "2\t3.5\tevent_accept_outgroup\t1.2\t7\t1\n"
                "6.25\t3.5\tmissed_trial\tn/a\t3\t1\n",
                encoding="utf-8",
            )
            trials, blocks = parse_event_file(path, "sub-999", "01")
            self.assertEqual(blocks, 1)
            self.assertEqual(len(trials), 2)
            self.assertEqual(trials[1].partner, "outgroup")
            self.assertEqual(trials[1].missed, 1)

    def test_synthetic_audit_writes_expected_tables(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary)
            bids = base / "bids" / "sub-999" / "func"
            bids.mkdir(parents=True)
            sample = base / "sample.csv"
            sample.write_text("subjID,younger,older\nsub-999,1,0\n", encoding="utf-8")
            events = bids / "sub-999_task-ultimatum_run-01_events.tsv"
            events.write_text(
                "onset\tduration\ttrial_type\tresponse_time\tOffer\tIsFairBlock\n"
                "1\t10\tblock_ingroup_fair\tn/a\tn/a\tn/a\n"
                "2\t3.5\tevent_reject_ingroup\t1.4\t2\t1\n"
                "6.25\t3.5\tmissed_trial\tn/a\t4\t1\n",
                encoding="utf-8",
            )
            output = base / "output"
            result = audit(base / "bids", sample, output)
            self.assertEqual(result, {"participants": 1, "runs": 1, "trials": 2, "misses": 1})
            with (output / "missed_trials_by_participant.tsv").open(newline="") as stream:
                row = next(csv.DictReader(stream, delimiter="\t"))
            self.assertEqual(row["missed_similar"], "1")


if __name__ == "__main__":
    unittest.main()
