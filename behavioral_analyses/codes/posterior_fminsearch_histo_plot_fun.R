posterior_fminsearch_histo_plot_fun = 
  function(sub_i_name, sub_i_fit_all, sub_i_fit, cvs_suff, fig_folder, w, h, bin_N, figure_dir) {
    # ### for testing
    # param_range = c(50, 10, 1) # alpha, tau, epsilon
    # sub_i_fit = 
    # cvs_suff = "_GUpaper_ugrRL.csv"
    # fig_folder = "ugRL_GUpaper"
    # bin_N = 50
    # w = 15
    # h = 5
    
    posterior_name = "alpha_i"
    # x = sub_i_fit[, posterior_name]
    # bw <- 2 * IQR(x) / length(x)^(1/3)
    post_alpha = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(binwidth = (max(sub_i_fit[,posterior_name])-min(sub_i_fit[,posterior_name]))/bin_N,
                     fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency",
           x = "alpha, post")
    
    posterior_name = "tau_i"
    # x = sub_i_fit[, posterior_name]
    # bw <- 2 * IQR(x) / length(x)^(1/3)
    post_tau = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(binwidth = (max(sub_i_fit[,posterior_name])-min(sub_i_fit[,posterior_name]))/bin_N,
                                    fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency",
           x = "tau, post")
    
    posterior_name = "epsilon_i"
    # x = sub_i_fit[, posterior_name]
    # bw <- 2 * IQR(x) / length(x)^(1/3)
    post_ep = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
      geom_histogram(binwidth = (max(sub_i_fit[,posterior_name])-min(sub_i_fit[,posterior_name]))/bin_N,
                                    fill = "lightblue", color = "black") +
      labs(title = posterior_name,
           y = "Frequency", 
           x = "epsilon, post") 
    
    prior_name = "alpha0"
    # x = sub_i_fit[, prior_name]
    # bw <- 2 * IQR(x) / length(x)^(1/3)
    pri_alpha = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N, fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency",
           x = "alpha, prior")
    
    prior_name = "tau0"
    # x = sub_i_fit[, prior_name]
    # bw <- 2 * IQR(x) / length(x)^(1/3)
    pri_tau = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N, 
                     fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency",
           x = "tau, prior")
    
    prior_name = "epsilon0"
    # x = sub_i_fit[, prior_name]
    # bw <- 2 * IQR(x) / length(x)^(1/3)
    pri_ep = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N,
                     fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency", 
           x = "epsilon, prior")
    
    prior_name = "norm0"
    # x = sub_i_fit[, prior_name]
    # bw <- 2 * IQR(x) / length(x)^(1/3)
    pri_norm = ggplot(sub_i_fit, aes_string(x = prior_name)) +
      geom_histogram(bins = bin_N,
                     fill = "lightgreen", color = "black") +
      labs(title = prior_name,
           y = "Frequency", 
           x = "norm0 scaled, prior") +
      coord_cartesian(xlim = c(0, 1)) +
      geom_vline(xintercept = norm0_df$norm0_mu[norm0_df$subjID== sub_i_name]/20, linetype = "solid", color = "red") +
      geom_vline(xintercept = norm0_df$norm0_low[norm0_df$subjID== sub_i_name]/20, linetype = "dashed", color = "red") +
      geom_vline(xintercept = norm0_df$norm0_high[norm0_df$subjID== sub_i_name]/20, linetype = "dashed", color = "red")
    
    
    # ### also plot all initials before filtering for sanity check
    # prior_name = "alpha0"
    # # x = sub_i_fit[, prior_name]
    # # bw <- 2 * IQR(x) / length(x)^(1/3)
    # pri_all_alpha = ggplot(sub_i_fit_all, aes_string(x = prior_name)) +
    #   geom_histogram(bins = 100,
    #                  fill = "lightgreen", color = "black") +
    #   labs(title = prior_name,
    #        y = "Frequency",
    #        x = "alpha, all prior")
    
    # prior_name = "tau0"
    # # x = sub_i_fit[, prior_name]
    # # bw <- 2 * IQR(x) / length(x)^(1/3)
    # pri_all_tau = ggplot(sub_i_fit_all, aes_string(x = prior_name)) +
    #   geom_histogram(bins = 100, fill = "lightgreen", color = "black") +
    #   labs(title = prior_name,
    #        y = "Frequency",
    #        x = "tau, all prior")
    
    # prior_name = "epsilon0"
    # # x = sub_i_fit[, prior_name]
    # # bw <- 2 * IQR(x) / length(x)^(1/3)
    # pri_all_ep = ggplot(sub_i_fit_all, aes_string(x = prior_name)) +
    #   geom_histogram(bins = 100,
    #                  fill = "lightgreen", color = "black") +
    #   labs(title = prior_name,
    #        y = "Frequency", 
    #        x = "epsilon, all prior")
    
    # prior_name = "norm0"
    # # x = sub_i_fit[, prior_name]
    # # bw <- 2 * IQR(x) / length(x)^(1/3)
    # pri_all_norm = ggplot(sub_i_fit_all, aes_string(x = prior_name)) +
    #   # geom_histogram(bins = bin_N,
    #   geom_histogram(bins = 100,
    #                  fill = "lightgreen", color = "black") +
    #   labs(title = prior_name,
    #        y = "Frequency", 
    #        x = "norm0 scaled, all prior") +
    #   coord_cartesian(xlim = c(0, 1)) +
    #   geom_vline(xintercept = norm0_df$norm0_mu[norm0_df$subjID== sub_i_name]/20, linetype = "solid", color = "red") +
    #   geom_vline(xintercept = norm0_df$norm0_low[norm0_df$subjID== sub_i_name]/20, linetype = "dashed", color = "red") +
    #   geom_vline(xintercept = norm0_df$norm0_high[norm0_df$subjID== sub_i_name]/20, linetype = "dashed", color = "red")
    
      
      p_post_pri = ggarrange(ggarrange(post_alpha, post_tau, post_ep, nrow = 1, ncol = 4), 
                             ggarrange(pri_alpha, pri_tau, pri_ep, pri_norm, nrow = 1, ncol = 4),
                             # ggarrange(pri_all_alpha, pri_all_tau, pri_all_ep, pri_all_norm, nrow = 1, ncol = 4),
                             nrow = 2, ncol = 1, heights = h, widths = w)
    
    ggsave(paste(figure_dir, fig_folder, paste(sub_i_name, fig_folder, "histo.png", sep = "_"), 
                 sep = "/"), p_post_pri, width = w, height = h)
    # print(p_post_pri)
    return()
  }