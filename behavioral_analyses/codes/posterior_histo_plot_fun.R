posterior_histo_plot_fun = function(i, cvs_suff, fig_folder) {
  # ### for testing
  # i = 1
  # cvs_suff = "_GUpaper_ugrRL.csv"
  # fig_folder = "ugRL_GUpaper"
  # ###
  
  bin_N = 50
  w = 15
  h = 5
  
  sub_i_name = participants_df$subjID[i]
  
  sub_i_csv = paste(sub_i_name, cvs_suff, sep = "")
  print(sub_i_csv)
  sub_i_fit = read.csv(paste(fits_dir, sub_i_csv, sep = "/"), header = T) %>% 
    .[2500:5000,]
  
  posterior_name = "alpha_i"
  p_alpha = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
    geom_histogram(bins = bin_N, fill = "lightblue", color = "black") +
    labs(title = posterior_name,
         y = "Frequency",
         x = "alpha")
  
  posterior_name = "epsilon_i"
  p_ep = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
    geom_histogram(bins = bin_N, fill = "lightblue", color = "black") +
    labs(title = posterior_name,
         y = "Frequency", 
         x = "epsilon")
  
  posterior_name = "tau_i"
  p_tau = ggplot(sub_i_fit, aes_string(x = posterior_name)) +
    geom_histogram(bins = bin_N, fill = "lightblue", color = "black") +
    labs(title = posterior_name,
         y = "Frequency",
         x = "tau")
  
  p_posteriors = ggarrange(p_alpha, p_ep, p_tau, nrow = 1, ncol = 3, heights = 6, widths = 8)
  
  ggsave(paste(figure_dir, fig_folder, paste(sub_i_name, fig_folder, "histo.png", sep = "_"), 
               sep = "/"), p_posteriors, width = w, height = h)
  return(p_posteriors)
}