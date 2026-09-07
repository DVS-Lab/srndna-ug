# SRNDNA Ultimatum Game

Analysis materials for **Older Adults Show Altered Default Mode and Executive
Control Network Connectivity during Fairness Decisions**
([bioRxiv DOI 10.1101/2025.08.13.670194](https://doi.org/10.1101/2025.08.13.670194)).

The repository contains behavioral/task data, analysis code, FSL templates,
network and ROI masks, and compact revision outputs. MRI images are distributed
through OpenNeuro dataset `ds003745`, not through this Git repository.

## Current reproducible entry points

From the repository root:

```bash
# Static checks, synthetic tests, and read-only audits
make test

# Reviewer-requested behavioral models, source tables, and figures
make reviewer-behavior

# Read-only local checks of tracked masks, L3 templates, and ROI influence
make reviewer-imaging-audit
```

The behavioral workflow requires R with `lme4`, `lmerTest`, `ggplot2`, and the
`scales` dependency used by ggplot2. The image-header audit requires FSL's
`fslhd` and `fslstats`; validation skips that check cleanly when FSL is absent.
Exact behavioral package versions are written to
`results/reviewer/tables/behavior_software_versions.tsv`.

## Repository map

- `bids/`: tracked BIDS events/metadata and task source. NIfTI data are ignored.
- `behavioral_analyses/data/`: submitted cleaned behavioral and covariate inputs.
- `code/`: active revision audits plus legacy preprocessing/FEAT scripts.
- `templates/`: submitted and later FSL templates; these are provenance
  evidence, not all interchangeable production entry points.
- `masks_SANS/` and `imaging_plots_SANS/`: focal submitted masks and plotting
  extracts used for low-cost verification.
- `results/reviewer/`: compact aggregate revision tables and figures.
- `logs/records/`: the manuscript-result manifest and durable audit records.
- `docs/SERVER_IMAGING_AUDIT.md`: read-only handoff for production imaging
  provenance and the gate before any image-level rerun.

Start with `code/WORKFLOW_AUDIT.md`. It distinguishes established submitted
analyses, revision analyses, provisional reconstructions, and unresolved
provenance. The machine-readable result index is
`logs/records/manuscript-result-manifest.tsv`.

## Data and privacy boundary

Reviewer scripts write participant-level derived rows under
`results/reviewer/private/`. That directory is ignored and remains local.
Only aggregate reviewer tables and figures belong in the active repository.
Raw DICOMs and other directly identifying source material are not included.

The analyses were **not preregistered**. Legacy text claiming otherwise was
incorrect and has been removed. Reviewer-requested work is labeled as revision
analysis rather than presented as part of the submitted workflow.

## Imaging boundary

The local checkout is suitable for behavioral reanalysis, template inspection,
mask/header checks, and preparation of server commands. It is not an
authoritative imaging-derivative store. Do not run the legacy L3 wrappers or
launch FEAT/FLAME/`randomise` from this checkout without first completing the
production provenance audit.

On the designated Linux host, follow `docs/SERVER_IMAGING_AUDIT.md`. The
collector copies only small metadata/design artifacts and never starts an
analysis. Any approved robustness run must use a new versioned output directory
and preserve the submitted result.

## Repository size

The initial checkout included 4.03 GiB of generated behavioral fit CSVs and
historical diagnostic figures. Those files were hashed, recorded in
`logs/records/generated-artifact-archive.tsv`, and moved to a verified local
archive. They are ignored in the active tree but remain recoverable locally and
from earlier commits. This reduces the working material substantially but does
not shrink the existing Git object database. A true repository-size reduction
requires a coordinated history rewrite and force-push, which has not been
performed.

## Historical workflows

Many older shell scripts and notebooks retain lab-specific absolute paths and
represent exploratory or superseded analyses. They remain for provenance while
the resubmission audit identifies the exact submitted result chain. Do not
assume that a file is active merely because it is tracked. The modern entry
points above are path-portable and covered by `make test`.

## Acknowledgments

This work was supported in part by NIH awards R21-MH113917 and R03-DA046733 to
David V. Smith, R15-MH122927 to Dominic S. Fareri, and a Scientific Research
Network on Decision Neuroscience and Aging pilot award (NIH R24-AG054355,
Gregory Samanez-Larkin, PI). See the manuscript for the full contributor list.
