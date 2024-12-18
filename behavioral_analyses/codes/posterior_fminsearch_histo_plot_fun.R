posterior_fminsearch_histo_plot_fun = 
  function(sub_i_name, sub_i_fit, params_df, cvs_suff, fig_folder, w_histo, h_histo, bin_N, figures_dir) {
    # ### for testing
    # param_range = c(50, 10, 1) # alpha, tau, epsilon
    # sub_i_fit = 
    # cvs_suff = "_GUpaper_ugrRL.csv"
    # fig_folder = "ugRL_GUpaper"
    # bin_N = 50
    # w = w_histo
    # h = h_histo
    
    posterior_name = "alpha_i"
    post_alpha = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(bins = bin_N,
                     fill = "lightblue", color = "black") +
      # geom_vline(xintercept = params_df["alpha", 2], linetype = "dashed", color = "darkblue") +
      # geom_vline(xintercept = params_df["alpha", 3], linetype = "solid", color = "darkblue") +
      labs(title = posterior_name,
           y = "Frequency",
           x = "alpha, post")
    
    posterior_name = "tau_i"
    post_tau = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(bins = bin_N,
                     fill = "lightblue", color = "black") +
      # geom_vline(xintercept = params_df["tau", 2], linetype = "dashed", color = "darkblue") +
      # geom_vline(xintercept = params_df["tau", 3], linetype = "solid", color = "darkblue") +
      labs(title = posterior_name,
           y = "Frequency",
           x = "tau, post")
    
    posterior_name = "epsilon_i"
    post_ep = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(bins = bin_N,
                     fill = "lightblue", color = "black") +
      # geom_vline(xintercept = params_df["epsilon", 2], linetype = "dashed", color = "darkblue") +
      # geom_vline(xintercept = params_df["epsilon", 3], linetype = "solid", color = "darkblue") +
      labs(title = posterior_name,
           y = "Frequency", 
           x = "epsilon, post") 
    
    prior_name = "alpha0"
    pri_alpha = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N, fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency",
           x = "alpha, prior")
    
    prior_name = "tau0"
  
    pri_tau = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N, 
                     fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency",
           x = "tau, prior")
    
    prior_name = "epsilon0"
    pri_ep = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N,
                     fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency", 
           x = "epsilon, prior")
    
    prior_name = "norm0"
    pri_norm =
      ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = 20,
                     fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency", 
           x = "norm0 scaled, prior") +
      coord_cartesian(xlim = c(0, 20)) +
      geom_vline(xintercept = norm0_df$norm0_mu[norm0_df$subjID== sub_i_name], linetype = "solid", color = "red") +
      geom_vline(xintercept = norm0_df$norm0_low[norm0_df$subjID== sub_i_name], linetype = "dashed", color = "red") +
      geom_vline(xintercept = norm0_df$norm0_high[norm0_df$subjID== sub_i_name], linetype = "dashed", color = "red")
    
    p_post_pri = ggarrange(ggarrange(post_alpha, post_tau, post_ep, nrow = 1, ncol = 4), 
                           ggarrange(pri_alpha, pri_tau, pri_ep, pri_norm, nrow = 1, ncol = 4),
                           # ggarrange(pri_all_alpha, pri_all_tau, pri_all_ep, pri_all_norm, nrow = 1, ncol = 4),
                           nrow = 2, ncol = 1, heights = h_histo, widths = w_histo)
    
    ggsave(paste(figures_dir, fig_folder, paste(sub_i_name, fig_folder, "histo.png", sep = "_"), 
                 sep = "/"), p_post_pri, width = w_histo, height = h_histo)
  }