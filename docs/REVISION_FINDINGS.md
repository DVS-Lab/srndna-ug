# Revision findings and response document updates

This file translates the completed repository audit into submission-facing
changes. It is a working author aid, not a reviewer response ready for upload.
Items labeled **server pending** must remain bracketed in the response until the
authoritative production derivatives have been collected and checked.

## Highest priority correction to the current draft

The draft response to Reviewer 1 Comment 1 says that the full fixed-effects
model will be reported with a participant random intercept because the random
offer slope did not converge. That is no longer the best-supported response.
With the current manuscript dataset, R 4.5.2, lme4 2.0.1, centered offer, and
`bobyqa`, the intended `(1 + Offer | participant)` model converges without a
singular fit. Five `allFit` optimizers agree.

Suggested replacement:

> We agree that nonconvergence is an estimation problem rather than evidence
> against the interaction. We re-fit the intended model after centering offer
> size and increasing the optimizer iteration budget. The model retained fixed
> effects of Offer Size, Age Group, Partner Similarity, and all interactions,
> with participant-specific intercepts and offer-size slopes. It converged
> without a singular fit, and five optimizers produced nearly identical
> estimates. The Offer Size × Age Group × Partner Similarity coefficient was
> 0.0667 (SE = 0.0945, z = 0.705, p = .481, 95% CI [-0.1186, 0.2519]; 47
> participants, 4,439 trials). A random-intercept-only robustness model led to
> the same inferential conclusion (β = 0.0258, SE = 0.0923, z = 0.279,
> p = .780, 95% CI [-0.1551, 0.2066]). We now report the intended
> random-intercept and random-offer-slope model as primary and avoid
> interpreting the nonsignificant interaction as evidence of equivalence.

## Completed reviewer analyses

### Behavioral fairness sensitivity

The tracked submitted score is reproducible to numerical precision. A unified
model with correlated participant interaction slopes is singular; an explicit
uncorrelated random-effects model is nonsingular. Its fixed Offer × Similarity
coefficient is -0.0530 (SE = 0.0622, z = -0.851, p = .395, 95% CI [-0.1750,
0.0690]). Unified participant slopes correlate r = .672 with the submitted
separate-model score. This supports reporting the unified quantity as a
robustness check, not silently replacing the submitted imaging covariate.

The submitted score does not differ detectably by age group: younger mean
-0.0419 (SD = 0.4640), older mean 0.0202 (SD = 0.6182), younger-minus-older
difference -0.0621, 95% CI [-0.3882, 0.2641], Welch p = .702. Positive values
mean a steeper offer-acceptance slope for similar than dissimilar partners;
negative values mean the reverse. The standardized difference is Hedges'
g = -0.11 (approximate 95% CI [-0.68, 0.46]).

**Author decision pending:** First compare the estimands, scaling, shrinkage,
distribution, age association, and r = .672 correspondence of the submitted
and unified participant measures. Do not construct or run a new ECN group model
unless that comparison supports it and the author decides it is scientifically
useful. The behavioral correlation is not evidence of equivalence or neural
robustness.

### Missed trials and response time

The 47-person sample contributes 6,768 trials. Participants missed 113 trials
(1.67%): 37 among younger adults and 76 among older adults. Mean misses were
1.48 (SD = 3.55) for younger and 3.45 (SD = 4.48) for older participants;
younger-minus-older difference -1.97 trials, 95% CI [-4.38, 0.43], Welch
p = .105. Partner identity for misses was reconstructed from the enclosing
block because the BIDS miss row omits it.

Mean response-selection latency was 0.392 s after choices appeared. The older
group coefficient was -0.1215 s (SE = 0.0560, p = .035); the similarity effect
and age-by-similarity interaction were not detected. Treat this secondary
result as descriptive/exploratory. The task source confirms that the partner,
offer, and selected response remained visible through the approximately 3.5-s
epoch, so first-level task regressors do not isolate deliberation.

### RT nuisance-event construction: production exception isolated

The curated BIDS event files contain 6,655 responded task trials, but only
5,724 matching `event_RT` rows. All 805 responded first trials of blocks lack
the companion row. An additional 126 non-first omissions occur in sub-143;
both of that participant's runs contain no `event_RT` rows at all. Thus 931
responded trials (13.99%) lack the source row used by the RT 3-column
conversion. The substantive task-event rows remain present for these trials.

The read-only production audit found all 94 rendered activation FSFs. For 92
runs, the current RT and RT-pmod files match the number of source `event_RT`
rows, all three main-task EV files are present, and the retained `design.mat`
contains nonconstant original RT and RT-pmod columns. The only unresolved runs
are both runs of sub-143: their FSFs remain, but current RT, RT-pmod, main-task
EVs, and `design.mat` files are absent. The tracked sub-143 source event TSVs
are byte-identical to OpenNeuro ds003745 snapshot 2.0.2 and retain all 72
responses per run, but contain no `event_RT` rows.

Do not silently regenerate EVs or rerun L1. First trace whether historical
sub-143 L1 outputs fed L2/L3 and whether small retained logs or statistics can
establish the submitted design. The source BIDS TSVs are public; the FSL
3-column EVs are generated derivatives and should be reproducibly rebuilt only
if a rerun is later approved.

The targeted sub-143 inventory found incomplete FEAT shells rather than
retained statistical outputs in the current `srndna-ug` tree. Both activation
L1 runs have rendered FSFs but no `design.mat`, `design.con`, or cope 7. The
expected DMN and ECN nPPI L1 artifacts were not found. Each activation/DMN/ECN
L2 directory has a rendered FSF, matrix, and contrasts, but no cope 4, 6, or 7
image.

This current-tree result is not the final production verdict. Every tracked L3
template includes sub-143, and every input path points to the legacy
`/ZPOOL/data/projects/srndna-ultimatum` root rather than the audited
`/ZPOOL/data/projects/srndna-ug` root. The focal 47-input templates specify
sub-143 at input 34 and would resolve to the relevant L2 cope 7; the separate
94-input condition-stacked templates specify that participant at inputs 34 and
81 for copes 4 and 6. The exact legacy root, L2 input declarations, and
submitted L3 `design.fsf` are therefore decisive.

### Partner ratings

There are 41 complete unique pre-task administrations and 39 complete unique
post-task administrations. Four participant-session files contain appended
duplicate administrations and five are missing at each session. Rather than
choosing among duplicates post hoc, the primary rating summary excludes those
sessions and records them in the local completeness audit.

No similar-versus-dissimilar human-partner contrast is detected for pre-task
fairness or likeability or post-task fairness, likeability, anger, or
satisfaction (all paired p > .38). These ratings do not directly measure
perceived similarity or belief that partners were real, so the design
limitation remains.

### Tracked group-design and influence checks

Both focal tracked L3 templates contain 47 unique participant inputs, are full
rank, and use one group-membership value. Scaled condition numbers are 4.54 and
4.56. The maximum no-intercept design variance factor is 4.62. tSNR and mean FD
are correlated (r = -0.796); this is a descriptive design fact, not a
methodological defect or a reason to remove either prespecified nuisance
covariate. No reduced-nuisance model is planned.

The selected DMN ROI diagnostic has one participant above Cook's 4/n screening
threshold. Across descriptive leave-one-participant-out fits, the older-group
coefficient ranges from -16.55 to -13.66 and remains small-p in every fit. This
does not answer the inferential concern because the ROI was selected from the
group result. It must not be used to exclude sub-138 or any other participant.
After production provenance is established, the audit should explain whether
the installed FSL version supports robust FLAME outlier deweighting for this
FLAME 1+2 model. Such a complete-sample sensitivity analysis remains
author-pending and must not redefine the primary result.

## Established task and model details

- Two 72-trial runs yielded 144 trials per participant: 48 computer, 48
  age-similar human, and 48 age-dissimilar human trials.
- Trial duration averages 3.5176 s. Within-block gaps average 0.7650 s;
  between-block gaps are approximately 8, 10, or 12 s.
- The first-level activation and nPPI templates retain computer constants and
  offer parametric modulators. Contrasts 8 and 10 encode social-versus-computer
  offer modulation and constant effects, respectively.
- The submitted DMN group template includes younger, older, younger-minus-older,
  and older-minus-younger contrasts on each participant's similar-minus-
  dissimilar cope. The ECN sensitivity template includes between-group and
  within-group positive/negative sensitivity contrasts.
- The focal tracked masks contain 26 and 23 voxels and are on a 2.973 × 2.973 ×
  3.220 mm grid. The manuscript's 2.97 × 2.97 × 2.80 mm value should be labeled
  as acquisition geometry if confirmed; it is not the focal output grid.

## Server pending items that must not be filled by inference

1. Exact analyzed fMRIPrep version/container and full preprocessing boilerplate.
2. Exact production BOLD and group-output headers.
3. Production `design.fsf`, `design.mat`, `design.con`, and `design.grp`
   identity relative to tracked templates.
4. Residual smoothness, search volume/resels, cluster tables, peaks, corrected
   probabilities, and confirmation that no post-statistics ROI mask was used.
5. Corrected main effects, within-age simple effects, and social-versus-computer
   results from existing contrasts.
6. Remaining first-level design correlations and RT/offer-modulator
   estimability, including downstream provenance for both sub-143 runs. The
   other 92 activation designs and current RT EV row counts are verified.
7. Exact behavior of robust FLAME outlier deweighting in the production FSL
   version, including compatibility, settings, and diagnostic outputs; do not
   run it without author approval.
8. A statistical comparison of the submitted and unified sensitivity measures;
   do not build a new ECN L3 model without a subsequent scientific decision.
9. An inventory classifying main/simple/computer-effect requests as existing,
   descriptive, genuinely new, or not scientifically recommended.

Use `docs/SERVER_IMAGING_AUDIT.md` to collect the evidence. Do not run the
tracked `L3stats_SANS.sh`; its current FSF redirection is defective.

## Interpretation changes supported now

- Replace equivalence-like null language with failure-to-detect language and
  report estimates and confidence intervals.
- Replace effective connectivity with task-dependent functional connectivity.
- Describe the partner manipulation as ostensible human partners varying in
  age similarity; do not claim demonstrated closeness, ingroup identification,
  or belief.
- Replace compensation, reorganization, and adaptive-recalibration claims with
  descriptive age-related connectivity differences. Compensation may be named
  only as a future hypothesis.
- Describe DMN and ECN effects as small corrected regional clusters and include
  the full inference details once recovered.
- Present comparable behavior and differing connectivity as co-occurring
  observations, not evidence that connectivity preserved behavior.
