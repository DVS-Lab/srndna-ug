# Imaging revision audit on the Linux analysis server

The local repository does not contain authoritative FEAT directories or enough
information to rerun imaging analyses. Run the read-only collection below on
the host that stores the submitted derivatives. It copies metadata and small
text artifacts only; it does not invoke FEAT, FLAME, `randomise`, or cluster
inference.

```bash
cd /path/to/srndna-ug

bash code/audit_server_imaging.sh \
  --fmriprep-root /path/to/analyzed/fmriprep \
  --group-dir /path/to/submitted/DMN-group-result.gfeat/cope7.feat \
  --output-dir logs/audits/server/dmn-submitted

bash code/audit_server_imaging.sh \
  --fmriprep-root /path/to/analyzed/fmriprep \
  --group-dir /path/to/submitted/ECN-sensitivity-group-result.gfeat/cope7.feat \
  --output-dir logs/audits/server/ecn-submitted
```

Replace the paths with the exact production directories; do not point at a
newer preprocessing tree merely because it is convenient. Return the two
audit directories to the analyst for review before any rerun.

For the RT stop-condition audit, use the 47-person tracked sample and the exact
production FSL tree. This command reads current EV files plus the retained
rendered activation FSFs/design matrices. It does not recreate an EV or invoke
FEAT:

```bash
python3 code/audit_server_rt_events.py \
  --bids-root source_data/bids \
  --ev-root /ZPOOL/data/projects/srndna-ug/derivatives/fsl/EVfiles \
  --l1-root /ZPOOL/data/projects/srndna-ug/derivatives/fsl \
  --output-dir logs/audits/server/rt-production
```

Return the printed `PASS` and `SUB143` lines plus
`logs/audits/server/rt-production/rt_production_summary.tsv`. The detailed
run table remains in the ignored audit directory and must not be committed.

## Questions the bundle must resolve

1. Which fMRIPrep version/container produced the analyzed BOLD files? The
   manuscript says 20.2.3, while tracked wrappers name 20.1.0 and 23.2.1.
2. Is the reported 2.97 x 2.97 x 2.80 mm value acquisition geometry, while the
   focal group maps are on a 2.973 x 2.973 x 3.220 mm normalized grid?
3. Do production `design.mat`, `design.con`, `design.grp`, and `design.fsf`
   match the tracked 47-input, one-contrast-per-participant reconstruction?
4. What are the exact corrected p-values, extents, peaks, search mask,
   smoothness/GRF values, and minimum significant extents for the 26-voxel DMN
   and 23-voxel ECN clusters under the submitted Z = 3.1 and p = .05 settings?
5. Are the sex, tSNR, FD, RT, and group-specific sensitivity EVs centered and
   sufficiently non-collinear in the production matrix?
6. Do the production RT 3-column EVs omit every responded first trial of a
   block, and do both sub-143 runs omit all RT events, as the curated BIDS
   source-event audit indicates? Are the affected trials retained in the main
   task EVs and what is the resulting design-matrix relationship?

## Analyses deliberately excluded from this audit

Do not prepare or run permutation/TFCE inference, a model dropping tSNR,
participant-deletion or leave-one-participant-out FLAME models, or an automatic
ECN rerun with the unified behavioral slope. The production audit is intended
to reconstruct the submitted inference and inventory existing outputs.

After the audit, possible robust FLAME outlier deweighting with all 47
participants may be described for author consideration. Genuinely missing
main/simple effects may likewise be proposed only after existing outputs are
inventoried. Any approved analysis must use a new versioned directory and must
not overwrite or relabel the submitted result.

The exact commands depend on the audited production matrix, masks, and FSL
version. This repository therefore gates all execution on the provenance bundle
and a subsequent scientific decision.
