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
  --ev-root /ZPOOL/data/projects/srndna-ultimatum/derivatives/fsl/EVfiles \
  --l1-root /ZPOOL/data/projects/srndna-ultimatum/derivatives/fsl \
  --path-map /data/projects/srndna-ultimatum=/ZPOOL/data/projects/srndna-ultimatum \
  --output-dir logs/audits/server/rt-production-legacy \
  --tracked-summary results/reviewer/tables/production_rt_ev_audit.tsv
```

The optional tracked output contains aggregate counts only and is safe to
commit. Small text inventories and production paths may also be committed when
they are useful for provenance. Do not commit NIfTI payloads or tables of
participant-level measurements merely because their paths are safe to share.

The initial 2026-09-07 run targeted the current `srndna-ug` derivative mirror,
not the production root. It found 92/94 retained activation designs with
matching current RT EV counts and nonconstant RT columns; both sub-143 runs
were incomplete. That result is retained as
`results/reviewer/tables/current_mirror_rt_ev_audit.tsv` and must not be
described as the production audit.

A targeted follow-up of the current `/ZPOOL/data/projects/srndna-ug` tree is
tracked in
`results/reviewer/tables/sub143_imaging_provenance_inventory.tsv`. Both
activation L1 directories retain rendered `design.fsf` files but not
`design.mat`, `design.con`, or cope 7. The expected DMN and ECN nPPI L1
artifacts were not found at those names. All three L2 directories retain
`design.fsf`, `design.mat`, and `design.con`, but none retains cope 4, 6, or 7
outputs. No scanned FSF in that current derivative tree referenced the expected
sub-143 L2 path.

Critically, all 15 tracked L3 templates explicitly include sub-143, but their
input paths use the legacy root `/ZPOOL/data/projects/srndna-ultimatum`, not the
current clone root `/ZPOOL/data/projects/srndna-ug`. The nine 47-input generic
templates place sub-143 at input 34; after substitution, the focal DMN/ECN
models expect that participant's L2 cope 7. The six 94-input condition-stacked
templates include 47 participants twice and place sub-143 at inputs 34 and 81,
using L2 copes 4 and 6. The current-tree shells therefore do not establish that
the submitted models lacked sub-143. Audit the exact legacy root and its L3
outputs before any regeneration.

The legacy-root check found all nine queried sub-143 L2 cope images
(activation, DMN nPPI, and ECN nPPI; copes 4, 6, and 7), with August 2021
timestamps. Its L2 FSFs point to the two legacy L1 runs for each analysis type.
The focal cope 7 and condition-stacked cope 4/6 inputs therefore exist in the
template-named store. The next RT audit must use legacy `--ev-root` and
`--l1-root` arguments. The current `srndna-ug` derivative mirror is not a
substitute for that production tree.

`--path-map` changes only how the audit resolves retained absolute path strings;
it does not modify an FSF or create a symlink. The old `/data/projects` values
remain preserved as production provenance.

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
