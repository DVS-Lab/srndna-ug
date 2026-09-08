# Repository of record

The repository of record for **Older Adults Show Altered Default Mode and
Executive Control Network Connectivity during Fairness Decisions** is:

`https://github.com/DVS-Lab/srndna-ug`, branch `main`

This decision separates version-controlled scientific provenance from large
external datasets and derivatives:

- `srndna-ug` owns the paper-specific code, immutable submitted templates,
  compact source tables needed for analysis, audit records, revision analyses,
  and submission-facing documentation.
- OpenNeuro `ds003745` owns the public BIDS dataset. The analyzed snapshot must
  be identified explicitly; the manuscript cites version 2.0.2.
- `/ZPOOL/data/projects/srndna-ultimatum` is the legacy production-derivative
  root named by the submitted FSL templates. It is evidence storage, not a
  second repository of record. NIfTI/FEAT payloads remain there and are
  referenced by inventories and checksums rather than copied into Git.
- `/ZPOOL/data/projects/srndna-ug` is the current Linux checkout/work area. Its
  local derivative mirror must not be assumed to be authoritative when it
  differs from the template-named legacy root.
- `DVS-Lab/srndna` is the historical grant-wide repository and
  `DVS-Lab/srndna-datapaper` is the all-task data-management/preprocessing
  repository. They are upstream historical sources, not revision targets for
  this paper.

Do not merge the Git histories of these repositories or bulk-copy one working
tree over another. Import a historical text artifact into `srndna-ug` only
when it bears on this paper, preserve its original content and source path, and
record why it is authoritative. Large source data belong on OpenNeuro; large
production derivatives belong in the legacy analysis store or its managed
backup.

Hard-coded paths in submitted FSFs are retained as provenance. New audit and
analysis entry points must accept roots as arguments or derive paths from the
checkout. If a rerun is approved later, render a new versioned FSF from a
portable template; never edit an old production FSF and relabel it as the
submitted analysis.

The local Git identity of the legacy production root remains to be recorded.
Whether it is an old checkout, a directory copied from another repository, or
a data-only tree does not change the designation above.
