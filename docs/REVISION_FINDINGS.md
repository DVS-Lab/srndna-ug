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
> p = .780, 95% CI [-0.1551, 0.2066]). We now report the converged maximal model
> as primary and avoid interpreting the nonsignificant interaction as evidence
> of equivalence.

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
negative values mean the reverse.

**Server pending:** Re-fit the focal ECN group result with the unified score
only after the exact production design and inputs are established. Do not claim
neural robustness from the behavioral correlation alone.

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
are strongly correlated (r = -0.796), so reduced-nuisance robustness is
warranted for the focal group results even though the tracked matrices remain
estimable.

The selected DMN ROI diagnostic has one participant above Cook's 4/n screening
threshold. Across descriptive leave-one-participant-out fits, the older-group
coefficient ranges from -16.55 to -13.66 and remains small-p in every fit. This
does not answer the inferential concern because the ROI was selected from the
group result. The reviewer response should say the descriptive plot is not
driven by a single observation, while reserving the corrected image-level
claim for the server analysis.

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
6. First-level design correlations and RT/offer-modulator estimability.
7. Image-level leave-one-out, reduced-nuisance, and alternate-inference
   robustness for the two focal clusters.
8. ECN focal-result robustness to the unified behavioral interaction slope.

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
