bestie_extract_fun = function(sub_i_name, cvs_suff, param_type_t){
  ### for testing
  # cvs_suff = "_alphaRANDtauRANDnorm0informedUPDATED_ugrRL_fminsearch_computer.csv"
  # param_type_t = "computer"
  # sub_i_name = participants_df$subjID[i]
  ### for testing
  
  sub_i_csv = paste(sub_i_name, cvs_suff, sep = "")
  sub_i_fit_all = read.csv(paste(fits_dir, sub_i_csv, sep = "/"), header = T) %>% 
    na.omit() # remove rows with NA
  sub_i_fit = sub_i_fit_all %>% 
    filter(exitflag == 1) %>%
    # filter(negLL <= quantile(negLL, probs = 1000/nrow(.))) %>%
    filter(negLL <= min(min(negLL)+1, quantile(negLL, probs = 1000/nrow(.)))) %>%
    select(negLL, prior_names, posterior_names)
  
  # generate 1000 samples from the remaining rows using bootstrapping
  random_1000 <- sample(1:nrow_df_i, size = 1000, replace = TRUE)
  sub_i_fit = sub_i_fit[random_1000,]
  
  
  
  # Calculate alpha density
  # alpha_i_1000 = sub_i_fit$alpha_i %>% sort()
  alpha_i_1000 = trimmed_vector ### for testing. to delete.
  
  density_alpha_1000 <- density(alpha_i_1000)
  
  # Find peaks in the density curve. The + 1 is necessary due to an indexing offset created by the diff() function.
  peaks_alpha <- which(diff(sign(diff(density_alpha_1000$y))) == -2) + 1 
  
  # Get density values of the peaks
  peaks_alpha_y <- density_alpha_1000$y[peaks_alpha]
  # Get the x value at the highest density
  peakmax_alpha_x <- density_alpha_1000$x[max(peaks_alpha)]
  peakmax_alpha_x ### for testing. to delete.
  
  # Calculate epsilon density
  epsilon_i_1000 = sub_i_fit$epsilon_i %>% sort()
  density_epsilon_1000 <- density(epsilon_i_1000)
  
  # Find peaks in the density curve. The + 1 is necessary due to an indexing offset created by the diff() function.
  peaks_epsilon <- which(diff(sign(diff(density_epsilon_1000$y))) == -2) + 1 
  
  # Get density values of the peaks
  peaks_epsilon_y <- density_epsilon_1000$y[peaks_epsilon]
  # Get the x value at the highest density
  peakmax_epsilon_x <- density_epsilon_1000$x[max(peaks_epsilon)]
  
  
  
  return(c(peakmax_alpha_x, peakmax_epsilon_x))
}