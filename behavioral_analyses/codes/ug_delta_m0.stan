// this function does not take conditions into account. it can only estimate one condition at a time

data {
  int<lower=1> N; // total N subjects
  int<lower=1> T_max; // max trial num of an sub
  array[N] int<lower=1, upper=T_max> Tsubj; //vector of trial num per sub
  array[N, T_max] real offer; // N by T matrix, N row of subject, T col of trials
  array[N, T_max] int<lower=0, upper=1> accept;
}

transformed data {
}

parameters {
// Declare all parameters as vectors for vectorizing
  vector<lower=0, upper=1>[3] mu; // group-level means of alpha, tau, epsilon
  vector<lower=0>[3] sigma; // group-level sd of alpha, tau, epsilon

  // Subject-level parameters, to scale sig and add to group mean
  vector<lower=-2, upper=2>[N] alpha_pr;  // alpha: Envy (sensitivity to norm prediction error), N of sd
  vector<lower=-2, upper=2>[N] tau_pr;    // tau: Inverse temperature, N of sd
  vector<lower=-2, upper=2>[N] ep_pr;     // ep: Norm adaptation rate, N of sd
}

transformed parameters {
  // total subject-level parameters
//   vector[N] alpha;
//   vector[N] tau;
//   vector[N] ep;

  vector<lower=0, upper=1>[N] alpha;
  vector<lower=0>[N] tau;
  // vector<lower=0, upper=1>[N] tau;
  vector<lower=0, upper=1>[N] ep;

  // alpha = Phi_approx(mu[1] + sigma[1] * alpha_pr); //Phi_approx naturally bounds param to 0-1
  // tau = Phi_approx(mu[2] + sigma[2] * tau_pr);
  // ep = Phi_approx(mu[3] + sigma[3] * ep_pr);
 
  alpha = mu[1] + sigma[1] * alpha_pr; //Phi_approx naturally bounds param to 0-1
  tau = mu[2] + sigma[2] * tau_pr;
  ep = mu[3] + sigma[3] * ep_pr;
}

model {
  // define priors for parameters
  mu  ~ uniform(0, 1);
  sigma ~ normal(0, 0.3); // sigma for uniform 0-1 distribution is about 0.3
  alpha_pr ~ normal(0, 1);
  tau_pr ~ normal(0, 1);
  ep_pr ~ normal(0, 1);

  for (i in 1:N) {

    real f; // define norm
    f = 10.0; // initialize norm

    for (t in 1:Tsubj[i]) {
      // calculate prediction error
      real PE = offer[i, t] - f; // define prediction error

      // Update utility
      real util = offer[i, t] - alpha[i] * fmax(f - offer[i, t], 0.0); // define utility

      // Sampling statement
      accept[i, t] ~ bernoulli_logit(util * tau[i]);

      // Update internal norm
      f += ep[i] * PE;

    } // end of t loop
  } // end of i loop
}

generated quantities {
  // For group level parameters
  real<lower=0, upper=1> mu_alpha;
  real<lower=0, upper=1> mu_tau;
  real<lower=0, upper=1> mu_ep;

  // For log likelihood calculation
  vector[N] log_lik;

  // For posterior predictive check
  array[N, T_max] int y_pred;
  y_pred = rep_array(0, N, T_max); // Set all posterior predictions to reject

  mu_alpha = mu[1];
  mu_tau   = mu[2];
  mu_ep    = mu[3];

  { // local section, this saves time and space
    for (i in 1:N) {

      real f;    // define internal norm
      f = 10.0;     // Initialize internal norm
      log_lik[i] = 0.0;   // Initialize log likelihood

      for (t in 1:Tsubj[i]) {
        
        real PE = offer[i, t] - f; // calculate prediction error
        real util = offer[i, t] - alpha[i] * fmax(f - offer[i, t], 0.0); // Update utility

        log_lik[i] += bernoulli_logit_lpmf(accept[i, t] | util * tau[i]); // Calculate log likelihood
        y_pred[i, t] = bernoulli_rng(inv_logit(util * tau[i])); // generate posterior prediction for current trial
        f += ep[i] * PE; // Update internal norm

      } // end of t loop
    } // end of i loop
  } // end of local section
}

