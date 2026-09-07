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

## Questions the bundle must resolve

1. Which fMRIPrep version/container produced the analyzed BOLD files? The
   manuscript says 20.2.3, while tracked wrappers name 20.1.0 and 23.2.1.
2. Is the reported 2.97 x 2.97 x 2.80 mm value acquisition geometry, while the
   focal group maps are on a 2.973 x 2.973 x 3.220 mm normalized grid?
3. Do production `design.mat`, `design.con`, `design.grp`, and `design.fsf`
   match the tracked 47-input, one-contrast-per-participant reconstruction?
4. What are the exact corrected p-values, extents, peaks, and smoothness values
   for the 26-voxel DMN and 23-voxel ECN clusters?
5. Are the sex, tSNR, FD, RT, and group-specific sensitivity EVs centered and
   sufficiently non-collinear in the production matrix?

## Conditional image-level work

After the read-only audit, create new versioned output directories for any
approved robustness work. Do not overwrite submitted results. Candidate checks
are:

- permutation/voxelwise inference for the two focal contrasts;
- leave-one-participant-out refits for influence;
- within-age simple effects using explicit estimable contrasts;
- main effects and social-versus-computer contrasts already supported by the
  first-level model.

The exact commands depend on the audited production matrix, masks, exchangeability
structure, and FSL version. Writing generic `randomise` commands before those
facts are known would create avoidable scientific risk, so this repository
deliberately gates execution on the provenance bundle.
