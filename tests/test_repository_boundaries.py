from __future__ import annotations

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def tracked_paths() -> list[str]:
    result = subprocess.run(
        ["git", "ls-files"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.splitlines()


class RepositoryBoundaryTests(unittest.TestCase):
    def test_full_bids_tree_is_not_tracked(self) -> None:
        paths = tracked_paths()
        self.assertFalse(any(path.startswith("bids/") for path in paths))

    def test_unrelated_computational_models_are_not_tracked(self) -> None:
        paths = tracked_paths()
        excluded = (
            "behavioral_analyses/codes/computation/",
            "behavioral_analyses/codes/RLtutorial_codeNdata/",
        )
        self.assertFalse(any(path.startswith(excluded) for path in paths))

    def test_curated_source_inputs_are_present(self) -> None:
        paths = tracked_paths()
        event_files = [
            path
            for path in paths
            if path.startswith("source_data/bids/") and path.endswith("_events.tsv")
        ]
        rating_files = [
            path
            for path in paths
            if path.startswith("source_data/partner_ratings/") and path.endswith(".csv")
        ]
        self.assertEqual(len(event_files), 195)
        self.assertEqual(len(rating_files), 192)

    def test_curated_bids_tree_has_no_imaging_payloads(self) -> None:
        paths = tracked_paths()
        payload_suffixes = (".nii", ".nii.gz", ".dcm")
        self.assertFalse(
            any(
                path.startswith("source_data/bids/") and path.endswith(payload_suffixes)
                for path in paths
            )
        )


if __name__ == "__main__":
    unittest.main()
