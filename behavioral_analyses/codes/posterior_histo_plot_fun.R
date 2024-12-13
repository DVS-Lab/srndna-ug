posterior_histo_plot_fun = function(sub_i_name, sub_i_fit, cvs_suff, fig_folder, w, h, bin_N, figure_dir) {
  # ### for testing
  # sub_i_fit = 
  # cvs_suff = "_GUpaper_ugrRL.csv"
  # fig_folder = "ugRL_GUpaper"
  # bin_N = 50
  # w = 15
  # h = 5
  
  sub_i_fit_2ndQ <- sub_i_fit %>%
    filter(negLL > quantile(negLL, 0.25) & negLL <= quantile(negLL, 0.50))
  
  posterior_name = "alpha_i"
  post_alpha = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
    geom_histogram(bins = bin_N, fill = "lightblue", color = "black") +
    labs(title = posterior_name,
         y = "Frequency",
         x = "alpha, post")
  
  posterior_name = "epsilon_i"
  post_ep = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
    geom_histogram(bins = bin_N, fill = "lightblue", color = "black") +
    labs(title = posterior_name,
         y = "Frequency", 
         x = "epsilon, post")
  
  posterior_name = "tau_i"
  post_tau = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
    geom_histogram(bins = bin_N, fill = "lightblue", color = "black") +
    labs(title = posterior_name,
         y = "Frequency",
         x = "tau, post")
  
  prior_name = "alpha0"
  pri_alpha = ggplot(sub_i_fit, aes_string(x = prior_name)) +
    geom_histogram(bins = bin_N, fill = "lightgreen", color = "black") +
    labs(title = prior_name,
         y = "Frequency",
         x = "alpha, prior")
  
  prior_name = "epsilon0"
  pri_ep = ggplot(sub_i_fit, aes_string(x = prior_name)) +
    geom_histogram(bins = bin_N, fill = "lightgreen", color = "black") +
    labs(title = prior_name,
         y = "Frequency", 
         x = "epsilon, prior")
  
  prior_name = "tau0"
  pri_tau = ggplot(sub_i_fit, aes_string(x = prior_name)) +
    geom_histogram(bins = bin_N, fill = "lightgreen", color = "black") +
    labs(title = prior_name,
         y = "Frequency",
         x = "tau, prior")
  
  p_post_pri = ggarrange(post_alpha, post_ep, post_tau, 
                           pri_alpha, pri_ep, pri_tau, 
                           nrow = 2, ncol = 3, heights = h, widths = w)
  
  ggsave(paste(figure_dir, fig_folder, paste(sub_i_name, fig_folder, "histo.png", sep = "_"), 
               sep = "/"), p_post_pri, width = w, height = h)
  # print(p_post_pri)
  return()
}