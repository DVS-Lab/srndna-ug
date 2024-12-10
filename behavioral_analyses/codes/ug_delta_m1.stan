# this function does not take conditions into account. it can only estimate one condition at a time

data {
  int<lower=1> N; // total N subjects
  int<lower=1> T; // max trial num of an sub
  int<lower=1, upper=T> Tsubj[N]; //vector of trial num per sub
  real offer[N, T]; // N by T matrix, N row of subject, T col of trials
  int<lower=-1, upper=1> accept[N, T];
}

transformed data {
}

parameters {
// Declare all parameters as vectors for vectorizing
  // Hyper(group)-parameters
  vector[3] mu; // group-level means of alpha, tau, epsilon
  vector<lower=0>[3] sigma; // group-level sd of alpha, tau, epsilon

  // Subject-level parameters, to scale sig and add to group mean
  vector[N] alpha_pr;  // alpha: Envy (sensitivity to norm prediction error), N of sd
  vector[N] tau_pr;    // tau: Inverse temperature, N of sd
  vector[N] ep_pr;     // ep: Norm adaptation rate, N of sd
}

transformed parameters {
  // total subject-level parameters
  real<lower=0, upper=1> alpha[N];
  // real<lower=0, upper=1> tau[N];
  real<lower=0> tau[N];
  real<lower=0, upper=1> ep[N];

  for (i in 1:N) {
    alpha[i] = Phi_approx(mu[1] + sigma[1] * alpha_pr[i]);
    tau[i]   = Phi_approx(mu[2] + sigma[2] * tau_pr[i]);
    ep[i]    = Phi_approx(mu[3] + sigma[3] * ep_pr[i]);
  }
}

model {
  // // Hyperparameters
  // mu  ~ normal(0, 1); // why hyperparameter?
  // sigma ~ normal(0, 0.2); // why hyperparameter?

  // individual parameters
  mu  ~ normal(0, 1)
  sigma ~ normal(0, 0.3) // sd of 0-1 uniform distribution is ~0.289
  alpha ~ normal(0, 1.0);
  tau   ~ normal(0, 1.0);
  ep    ~ normal(0, 1.0);

  for (i in 1:N) {
    // Define values
    real f;    // Internal norm
    real PE;   // Prediction error
    real util; // Utility of offer

    // Initialize values
    f = 10.0;

    for (t in 1:Tsubj[i]) {
      // calculate prediction error
      PE = offer[i, t] - f;

      // Update utility
      util = offer[i, t] - alpha[i] * fmax(f - offer[i, t], 0.0);

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
  real log_lik[N];

  // For posterior predictive check
  real y_pred[N, T];

  // Set all posterior predictions to 0 (avoids NULL values)
  for (i in 1:N) {
    for (t in 1:T) {
      y_pred[i, t] = -1;
    }
  }

  mu_alpha = Phi_approx(mu[1]);
  mu_tau   = Phi_approx(mu[2]);
  mu_ep    = Phi_approx(mu[3]);

  { // local section, this saves time and space
    for (i in 1:N) {
      // Define values
      real f;    // Internal norm
      real PE;   // prediction error
      real util; // Utility of offer

      // Initialize values
      f = 10.0;
      log_lik[i] = 0.0;

      for (t in 1:Tsubj[i]) {
        // calculate prediction error
        PE = offer[i, t] - f;

        // Update utility
        util = offer[i, t] - alpha[i] * fmax(f - offer[i, t], 0.0);

        // Calculate log likelihood
        log_lik[i] += bernoulli_logit_lpmf(accept[i, t] | util * tau[i]);

        // generate posterior prediction for current trial
        y_pred[i, t] = bernoulli_rng(inv_logit(util * tau[i]));

        // Update internal norm
        f += ep[i] * PE;

      } // end of t loop
    } // end of i loop
  } // end of local section
}

