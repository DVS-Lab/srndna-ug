posterior_histo_plot_fun = 
  function(sub_i_name, sub_i_fit, param_range, cvs_suff, fig_folder, w, h, bin_N, bin_N_scaled, figure_dir) {
    # ### for testing
    # param_range = c(50, 10, 1) # alpha, tau, epsilon
    # sub_i_fit = 
    # cvs_suff = "_GUpaper_ugrRL.csv"
    # fig_folder = "ugRL_GUpaper"
    # bin_N = 50
    # w = 15
    # h = 5
    
    posterior_name = "alpha_i"
    sub_i_fit[, posterior_name] = sub_i_fit[, posterior_name]
    post_alpha = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(binwidth = param_range[1]/bin_N,  fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency",
           x = "alpha, post") +
      coord_cartesian(xlim = c(0, param_range[1]))
    
    posterior_name = "tau_i"
    sub_i_fit[, posterior_name] = sub_i_fit[, posterior_name]
    post_tau = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(binwidth = param_range[2]/bin_N,  fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency",
           x = "tau, post") +
      coord_cartesian(xlim = c(0, param_range[2]))
    
    posterior_name = "epsilon_i"
    sub_i_fit[, posterior_name] = sub_i_fit[, posterior_name]
    post_ep = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(binwidth = param_range[3]/bin_N,  fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency", 
           x = "epsilon, post") + 
      coord_cartesian(xlim = c(0, param_range[3]))  
    
    posterior_name = "alpha_i"
    sub_i_fit[, posterior_name] = sub_i_fit[, posterior_name]/param_range[1]
    post_alpha_scaled = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(bins = bin_N_scaled,  fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency",
           x = "alpha scaled, post")
    # coord_cartesian(xlim = c(0, 1))
    
    posterior_name = "tau_i"
    sub_i_fit[, posterior_name] = sub_i_fit[, posterior_name]/param_range[2]
    post_tau_scaled = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(bins = bin_N_scaled,  fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency",
           x = "tau scaled, post")
    # coord_cartesian(xlim = c(0, 1))
    
    posterior_name = "epsilon_i"
    sub_i_fit[, posterior_name] = sub_i_fit[, posterior_name]/param_range[3]
    post_ep_scaled = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(bins = bin_N_scaled,  fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency", 
           x = "epsilon scaled, post")
    # coord_cartesian(xlim = c(0, 1))
    
    prior_name = "alpha0"
    sub_i_fit[, prior_name] = sub_i_fit[, prior_name]/param_range[1]
    pri_alpha_scaled = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N_scaled,  fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency",
           x = "alpha scaled, prior")
    coord_cartesian(xlim = c(0, 1))
    
    prior_name = "tau0"
    sub_i_fit[, prior_name] = sub_i_fit[, prior_name]/param_range[2]
    pri_tau_scaled = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N_scaled,  fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency",
           x = "tau scaled, prior")
    coord_cartesian(xlim = c(0, 1))
    
    prior_name = "epsilon0"
    sub_i_fit[, prior_name] = sub_i_fit[, prior_name]/param_range[3]
    pri_ep_scaled = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N_scaled,  fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency", 
           x = "epsilon scaled, prior")
    coord_cartesian(xlim = c(0, 1))
    
    prior_name = "norm0"
    sub_i_fit[, prior_name] = sub_i_fit[, prior_name]/20
    pri_norm_scaled = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(binwidth = 1/bin_N_scaled,  fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency", 
           x = "norm0 scaled, prior") +
      coord_cartesian(xlim = c(0, 1)) +
      geom_vline(xintercept = norm0_df$norm0_mu[norm0_df$subjID== sub_i_name]/20, linetype = "solid", color = "red") +
      geom_vline(xintercept = norm0_df$norm0_low[norm0_df$subjID== sub_i_name]/20, linetype = "dashed", color = "red") +
      geom_vline(xintercept = norm0_df$norm0_high[norm0_df$subjID== sub_i_name]/20, linetype = "dashed", color = "red")
      
      p_post_pri = ggarrange(ggarrange(post_alpha, post_tau, post_ep, nrow = 1, ncol = 4), 
                             ggarrange(post_alpha_scaled, post_tau_scaled, post_ep_scaled, nrow = 1, ncol = 4), 
                             ggarrange(pri_alpha_scaled, pri_tau_scaled, pri_ep_scaled, pri_norm_scaled, nrow = 1, ncol = 4),
                             nrow = 3, ncol = 1, heights = h, widths = w)
    
    ggsave(paste(figure_dir, fig_folder, paste(sub_i_name, fig_folder, "histo.png", sep = "_"), 
                 sep = "/"), p_post_pri, width = w, height = h)
    # print(p_post_pri)
    return()
  }