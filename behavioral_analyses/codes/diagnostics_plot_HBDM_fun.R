diagnostics_plot_HBDM_fun = function(model_name, model_fit) {
  
  ## for testing ##
  # model_fit = computer_fit
  # model_name = "computer_fit"
  #################
  
  ### make folder to keep all plots
  dir.create(file.path(figure_dir, model_name))
  
  ### plot and save
  plot_name = paste(model_name, "trace.png", sep = "_")
  plot(model_fit, type = "trace")
  ggsave(paste(figure_dir, model_name, plot_name, sep = "/"), width = w, height = h, device = "png")
  
  plot_name = paste(model_name, "dist.png", sep = "_")
  plot(model_fit, type = "dist")
  ggsave(paste(figure_dir, model_name, plot_name, sep = "/"), width = w, height = h, device = "png")
  
  plot_name = paste(model_name, "simple.png", sep = "_")
  plot(model_fit, type = "simple")
  ggsave(paste(figure_dir, model_name, plot_name, sep = "/"), width = w, height = h, device = "png")
}

