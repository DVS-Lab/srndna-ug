corrMatrix_plot_fun = function(sub_i_name, data_df, plot_title, w, h, figure_dir, fig_folder){
  ## input
  # data_df - data, wide format
  # plot_title - string
  # figure_dir - figure target folder
  ### for testing
  # data_df = sub_i_fit
  # plot_title = "alpha50, tau 20"
  # figure_dir = figure_dir
  ####
  
  corrMatrix_df = corrMatrix_upper_fun(data_df[,-1]) # if df's first column is subjID or other index info, use date_df[,-1] to remove the column
  corrMatrix_df$value = round(corrMatrix_df$value, 4)
  corMatrix_labels = colnames(data_df[,-1])
  
  matrix_plot <-
    ggplot(data = corrMatrix_df, aes(Var1, Var2, fill = sigR_color)) +
    geom_tile(color = "white") +
    scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                         midpoint = 0, limit = c(-1,1), space = "Lab", 
                         name="Correlation\nCoefficients") +
    labs(x = NULL, y = NULL,
         # title="Correlations Matrix", subtitle="pairwise correlation coefficients (alpha = 0.05)") + 
         title = plot_title) + 
    # geom_text(aes(Var1, Var2, label = value), color = "black", size = 3)
    scale_x_discrete(labels=corMatrix_labels, position = "top") +
    scale_y_discrete(labels=corMatrix_labels) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, 
                                     hjust = 0, # left-justified
                                     color = "black"),
          axis.text.y = element_text(color = "black", size = 12),
          plot.title = element_text(hjust = 0.5, face = "bold"),
          plot.subtitle = element_text(hjust = 0.5),
          legend.position = "right") +
    coord_fixed()
  # matrix_plot
  # print(matrix_plot)
  fig_name = paste(sub_i_name, "pri_post_HeatMap.jpg", sep = "_")
  ggsave(paste(figure_dir, fig_folder, fig_name, sep = "/"), width = w, height = h)
}