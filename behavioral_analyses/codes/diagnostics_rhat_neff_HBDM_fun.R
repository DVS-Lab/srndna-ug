diagnostics_rhat_neff_HBDM_fun = function(model_fit) {
  ## for testing
  # model_fit = computer_fit
  ##
  
  # r-hat check, should be smaller than 1.05
  rhat_max_thresh = 1.05
  rhat_all = rstan::summary(model_fit$fit)$summary[,"Rhat"]
  if (max(na.omit(rhat_all)) > rhat_max_thresh) {
    rhat_N = length(rhat_all)
    rhat_large_N = sum(rhat_all>rhat_max_thresh)
    print(sprintf("Warning: r-hat check: %d out of %d are larger than %.02f", rhat_N, rhat_large_N, rhat_max_thresh))
  } else {
    print(sprintf("Good to go: all r-hats are smaller than %.02f, max = %.02f", rhat_max_thresh, max(na.omit(rhat_all))))
  }
  
  # n_effective check (a measure of “how much independent information there is in autocorrelated chains” (Kruschke 2015, p182-3). therefore the number can have decimal places)
  n_eff_min_thresh = 100
  n_eff_all = rstan::summary(model_fit$fit)$summary[,"n_eff"]
  if (min(na.omit(n_eff_all)) < n_eff_min_thresh) {
    n_eff_N = length(n_eff_all)
    n_eff_small_N = sum(n_eff_all<n_eff_min_thresh)
    print(sprintf("Warning: number of effective samples check: %.02f out of %d are larger than %d", n_eff_N, n_eff_small_N, n_eff_min_thresh))
  } else {
    print(sprintf("Good to go: all numbers of effective samples are larger than %d, min = %.02f", n_eff_min_thresh, min(na.omit(n_eff_all))))
  }
}