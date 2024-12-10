// generated with brms 2.21.0
functions {
 /* compute correlated group-level effects
  * Args:
  *   z: matrix of unscaled group-level effects
  *   SD: vector of standard deviation parameters
  *   L: cholesky factor correlation matrix
  * Returns:
  *   matrix of scaled group-level effects
  */
  matrix scale_r_cor(matrix z, vector SD, matrix L) {
    // r is stored in another dimension order than z
    return transpose(diag_pre_multiply(SD, L) * z);
  }
  /* Wiener diffusion log-PDF for a single response
   * Args:
   *   y: reaction time data
   *   dec: decision data (0 or 1)
   *   alpha: boundary separation parameter > 0
   *   tau: non-decision time parameter > 0
   *   beta: initial bias parameter in [0, 1]
   *   delta: drift rate parameter
   * Returns:
   *   a scalar to be added to the log posterior
   */
   real wiener_diffusion_lpdf(real y, int dec, real alpha,
                              real tau, real beta, real delta) {
     if (dec == 1) {
       return wiener_lpdf(y | alpha, tau, beta, delta);
     } else {
       return wiener_lpdf(y | alpha, tau, 1 - beta, - delta);
     }
   }
}
data {
  int<lower=1> N;  // total number of observations
  vector[N] Y;  // response variable
  array[N] int<lower=0,upper=1> dec;  // decisions
  int<lower=1> K;  // number of population-level effects
  matrix[N, K] X;  // population-level design matrix
  int<lower=1> Kc;  // number of population-level effects after centering
  // data for group-level effects of ID 1
  int<lower=1> N_1;  // number of grouping levels
  int<lower=1> M_1;  // number of coefficients per level
  array[N] int<lower=1> J_1;  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_1_1;
  vector[N] Z_1_2;
  int<lower=1> NC_1;  // number of group-level correlations
  // data for group-level effects of ID 2
  int<lower=1> N_2;  // number of grouping levels
  int<lower=1> M_2;  // number of coefficients per level
  array[N] int<lower=1> J_2;  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_2_bs_1;
  // data for group-level effects of ID 3
  int<lower=1> N_3;  // number of grouping levels
  int<lower=1> M_3;  // number of coefficients per level
  array[N] int<lower=1> J_3;  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_3_ndt_1;
  // data for group-level effects of ID 4
  int<lower=1> N_4;  // number of grouping levels
  int<lower=1> M_4;  // number of coefficients per level
  array[N] int<lower=1> J_4;  // grouping indicator per observation
  // group-level predictor values
  vector[N] Z_4_bias_1;
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
  real min_Y = min(Y);
  matrix[N, Kc] Xc;  // centered version of X without an intercept
  vector[Kc] means_X;  // column means of X before centering
  for (i in 2:K) {
    means_X[i - 1] = mean(X[, i]);
    Xc[, i - 1] = X[, i] - means_X[i - 1];
  }
}
parameters {
  vector[Kc] b;  // regression coefficients
  real Intercept;  // temporary intercept for centered predictors
  real Intercept_bs;  // temporary intercept for centered predictors
  real Intercept_ndt;  // temporary intercept for centered predictors
  real Intercept_bias;  // temporary intercept for centered predictors
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations
  matrix[M_1, N_1] z_1;  // standardized group-level effects
  cholesky_factor_corr[M_1] L_1;  // cholesky factor of correlation matrix
  vector<lower=0>[M_2] sd_2;  // group-level standard deviations
  array[M_2] vector[N_2] z_2;  // standardized group-level effects
  vector<lower=0>[M_3] sd_3;  // group-level standard deviations
  array[M_3] vector[N_3] z_3;  // standardized group-level effects
  vector<lower=0>[M_4] sd_4;  // group-level standard deviations
  array[M_4] vector[N_4] z_4;  // standardized group-level effects
}
transformed parameters {
  matrix[N_1, M_1] r_1;  // actual group-level effects
  // using vectors speeds up indexing in loops
  vector[N_1] r_1_1;
  vector[N_1] r_1_2;
  vector[N_2] r_2_bs_1;  // actual group-level effects
  vector[N_3] r_3_ndt_1;  // actual group-level effects
  vector[N_4] r_4_bias_1;  // actual group-level effects
  real lprior = 0;  // prior contributions to the log posterior
  // compute actual group-level effects
  r_1 = scale_r_cor(z_1, sd_1, L_1);
  r_1_1 = r_1[, 1];
  r_1_2 = r_1[, 2];
  r_2_bs_1 = (sd_2[1] * (z_2[1]));
  r_3_ndt_1 = (sd_3[1] * (z_3[1]));
  r_4_bias_1 = (sd_4[1] * (z_4[1]));
  lprior += student_t_lpdf(Intercept | 3, 1.7, 2.5);
  lprior += normal_lpdf(Intercept_bs | -0.6, 1.3);
  lprior += logistic_lpdf(Intercept_bias | 0, 1);
  lprior += student_t_lpdf(sd_1 | 3, 0, 2.5)
    - 2 * student_t_lccdf(0 | 3, 0, 2.5);
  lprior += lkj_corr_cholesky_lpdf(L_1 | 1);
  lprior += student_t_lpdf(sd_2 | 3, 0, 2.5)
    - 1 * student_t_lccdf(0 | 3, 0, 2.5);
  lprior += student_t_lpdf(sd_3 | 3, 0, 2.5)
    - 1 * student_t_lccdf(0 | 3, 0, 2.5);
  lprior += student_t_lpdf(sd_4 | 3, 0, 2.5)
    - 1 * student_t_lccdf(0 | 3, 0, 2.5);
}
model {
  // likelihood including constants
  if (!prior_only) {
    // initialize linear predictor term
    vector[N] mu = rep_vector(0.0, N);
    // initialize linear predictor term
    vector[N] bs = rep_vector(0.0, N);
    // initialize linear predictor term
    vector[N] ndt = rep_vector(0.0, N);
    // initialize linear predictor term
    vector[N] bias = rep_vector(0.0, N);
    mu += Intercept + Xc * b;
    bs += Intercept_bs;
    ndt += Intercept_ndt;
    bias += Intercept_bias;
    for (n in 1:N) {
      // add more terms to the linear predictor
      mu[n] += r_1_1[J_1[n]] * Z_1_1[n] + r_1_2[J_1[n]] * Z_1_2[n];
    }
    for (n in 1:N) {
      // add more terms to the linear predictor
      bs[n] += r_2_bs_1[J_2[n]] * Z_2_bs_1[n];
    }
    for (n in 1:N) {
      // add more terms to the linear predictor
      ndt[n] += r_3_ndt_1[J_3[n]] * Z_3_ndt_1[n];
    }
    for (n in 1:N) {
      // add more terms to the linear predictor
      bias[n] += r_4_bias_1[J_4[n]] * Z_4_bias_1[n];
    }
    bs = exp(bs);
    ndt = exp(ndt);
    bias = inv_logit(bias);
    for (n in 1:N) {
      target += wiener_diffusion_lpdf(Y[n] | dec[n], bs[n], ndt[n], bias[n], mu[n]);
    }
  }
  // priors including constants
  target += lprior;
  target += std_normal_lpdf(to_vector(z_1));
  target += std_normal_lpdf(z_2[1]);
  target += std_normal_lpdf(z_3[1]);
  target += std_normal_lpdf(z_4[1]);
}
generated quantities {
  // actual population-level intercept
  real b_Intercept = Intercept - dot_product(means_X, b);
  // actual population-level intercept
  real b_bs_Intercept = Intercept_bs;
  // actual population-level intercept
  real b_ndt_Intercept = Intercept_ndt;
  // actual population-level intercept
  real b_bias_Intercept = Intercept_bias;
  // compute group-level correlations
  corr_matrix[M_1] Cor_1 = multiply_lower_tri_self_transpose(L_1);
  vector<lower=-1,upper=1>[NC_1] cor_1;
  // additionally sample draws from priors
  real prior_Intercept = student_t_rng(3,1.7,2.5);
  real prior_Intercept_bs = normal_rng(-0.6,1.3);
  real prior_Intercept_bias = logistic_rng(0,1);
  real prior_sd_1 = student_t_rng(3,0,2.5);
  real prior_cor_1 = lkj_corr_rng(M_1,1)[1, 2];
  real prior_sd_2 = student_t_rng(3,0,2.5);
  real prior_sd_3 = student_t_rng(3,0,2.5);
  real prior_sd_4 = student_t_rng(3,0,2.5);
  // extract upper diagonal of correlation matrix
  for (k in 1:M_1) {
    for (j in 1:(k - 1)) {
      cor_1[choose(k - 1, 2) + j] = Cor_1[j, k];
    }
  }
  // use rejection sampling for truncated priors
  while (prior_sd_1 < 0) {
    prior_sd_1 = student_t_rng(3,0,2.5);
  }
  while (prior_sd_2 < 0) {
    prior_sd_2 = student_t_rng(3,0,2.5);
  }
  while (prior_sd_3 < 0) {
    prior_sd_3 = student_t_rng(3,0,2.5);
  }
  while (prior_sd_4 < 0) {
    prior_sd_4 = student_t_rng(3,0,2.5);
  }
}