# Repository history rewrite

Git history was rewritten on 2026-09-07 to make this repository a focused,
source-oriented record of the SRNDNA Ultimatum Game manuscript and resubmission.
The pre-rewrite remote tip was
`677b746e7706dd70332aa57e4215e8be62624509`.

## Removed from every retained revision

- 4,218 generated behavioral-fit and diagnostic-figure paths recorded in
  `logs/records/generated-artifact-archive.tsv`;
- all historical contents of `behavioral_analyses/fits/`, including older
  RL/HBDM CSV, RDA, MAT, LOO, and WAIC outputs that predated the manifest;
- `behavioral_analyses/codes/computation/` and
  `behavioral_analyses/codes/RLtutorial_codeNdata/`;
- `code/Delta_Learning.ipynb` and an editor swap file; and
- the legacy root `bids/` tree, including unrelated stimulus/task logs.

The verified local artifact archive and its SHA-256 manifest remain the recovery
source for the 4,218 files present at cleanup time. Older revisions of generated
fit files that were already absent when the manifest was made were intentionally
discarded. The compact manuscript inputs under `source_data/`, active revision
code, submitted templates, masks, and manuscript-relevant outputs were retained.

## Result

The packed Git object database decreased from 3.70 GiB to approximately 142 MiB.
The history now contains 295 commits; three commits containing only purged
material became empty and were dropped. Every retained commit has a new ID.

## Updating an existing clone

Do not run `git pull` across this boundary. First preserve or confirm any local,
ignored data and ensure `git status` is clean. Then fetch the rewritten branch,
reset the local branch to it, expire references to the old history, and repack:

```bash
git fetch origin
git switch main
git reset --hard origin/main
git reflog expire --expire=now --all
git gc --prune=now
```

Ignored local files are not changed by the reset. A fresh clone is the simplest
alternative when no ignored local data need to be preserved.
