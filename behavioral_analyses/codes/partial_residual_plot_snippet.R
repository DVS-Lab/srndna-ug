## get partial residuals
# ```{r}
library(LMMstar)

LMM_df = plot_df # data for plotting/analysis
formula_string = "DV ~ age_bi * sensitivity_in_out + tsnr + fd_mean + RT"
formula_LMM = as.formula(formula_string)
focal_var_names = c("(Intercept)", 
                    "age_bi", "sensitivity_in_out")

# compute partial residual using LMM
pres_LMM_fit = lmm(formula_LMM, data = LMM_df) # use LMM
LMM_df$partial_residual <- residuals(pres_LMM_fit, type = "partial", 
                                     variable = focal_var_names)
# ```

## plot and save
# ```{r}
x_label = "Fairness Senstivity (logit)\nIngroup > Outgroup"
y_label = "beta\n(partial residual)"
title_label = "ECN-mPFC Connectivity's Sensitivity to Fairness\nIngroup > Outgroup"

color_label = "Age Group"
color_age = c("older" = "#003c66", "younger"= "#0098ff")

figure_name = "ECN_mPFC_in-out_age_BehFairSensitivity"

p_scatter =
  ggplot(plot_df, aes(x = sensitivity_in_out, y = DV, color = age_bi)) + 
  geom_point(alpha = data_point_alpha, size = data_point_size, show.legend = FALSE) +
  geom_smooth(formula = "y~x", method = "lm", 
              se = TRUE,
              linetype = "solid",
              linewidth = 2, 
              alpha = 0.2) +
  scale_color_manual(values = color_age) +
  guides(color = guide_legend(override.aes = list(fill = NA))) +
  theme_classic() +
  labs(x = x_label, y = y_label, color = color_label, title = NULL) +
  guides(color = guide_legend(override.aes = list(fill = NA))) +
  theme(axis.line = element_line(linewidth = 1, colour = "black", linetype=1),
        legend.title = element_text(face = "bold"),
        axis.text.x = element_text(size = axis_text), 
        axis.text.y = element_text(size = axis_text), 
        axis.title.x = element_text(size = axis_title, face="bold"), 
        axis.title.y = element_text(size = axis_title, face="bold"))
# legend.position="bottom left", legend.box = "horizontal")
# legend.position="none")

ggsave(paste(figure_dir, paste(figure_name, "scatter_classic_titleNULL.png", sep = "_"),
             sep = "/"), p_scatter, width = w*1.1, height = h)
# ```