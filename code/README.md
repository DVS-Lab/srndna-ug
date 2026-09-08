# Analysis code

## Active revision workflow

| Entry point | Purpose | Mutates imaging derivatives? |
| --- | --- | --- |
| `validate_workflow.sh` | Shell/Python/R syntax, unit tests, task-event audit, and optional FSL header checks | No |
| `audit_task_events.py` | Reconstruct one task row per BIDS trial, recover the partner for misses, and audit timing | No |
| `audit_server_rt_events.py` | Compare the 47-person source RT rows, production 3-column EV files, rendered activation FSFs, and retained design-matrix RT columns | No |
| `analyze_reviewer_behavior.R` | Primary/refit logistic models, unified sensitivity, misses, RT, ratings, figures, and exact tables | No |
| `audit_image_headers.py` | Checksum and inspect tracked focal masks with `fslhd`/`fslstats` | No |
| `audit_l3_designs.R` | Parse tracked submitted L3 templates; audit inputs, rank, conditioning, EVs, and contrasts | No |
| `audit_roi_influence.R` | Descriptive selected-DMN-ROI influence and leave-one-out coefficient audit | No |
| `audit_server_imaging.sh` | Copy production metadata/design/header evidence into a read-only audit bundle | No |
| `archive_generated_artifacts.py` | Inventory, hash, move, and verify explicitly selected generated artifacts in a local archive | No imaging changes |
| `run_logged.sh` | Execute active commands with timestamped local logs and preserved exit status | No |

Use the root `Makefile` rather than calling several scripts by hand. Aggregate
outputs go to `results/reviewer/tables/` and `results/reviewer/figures/`.
Participant-level rows go to the ignored `results/reviewer/private/` directory.

## Scientific provenance

Read `WORKFLOW_AUDIT.md` before interpreting or changing any legacy pipeline.
It records the submitted first- and third-level models, open questions, result
status, task-timing interpretation, and the separation between submitted and
revision analyses.

The currently tracked `L3stats_SANS.sh` is historical and contains a broken
redirection in its FSF-rendering command. It is not an active reproduction
entry point. Several other legacy scripts hard-code old `/ZPOOL` or personal
paths. They are preserved as provenance until the exact production artifacts
are collected; their presence does not make them safe to run.

## Server work

The only active server-side commands at this stage are the read-only provenance
and RT-design audits documented in `../docs/SERVER_IMAGING_AUDIT.md`. They
intentionally do not provide generic FEAT or permutation commands before the
production design, masks, and software versions are verified.

## Tests

```bash
make test
```

Synthetic tests cover missed-trial partner recovery, RT-EV/design matching, and
image-header parsing.
The validation target also runs the event audit against the current 47-person
sample and checks that active revision scripts contain no personal absolute
paths.
