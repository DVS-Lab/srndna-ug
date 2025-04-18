## created by Jen Yang
## created on 4.18.2025
# last modified on 4.18.2025

## snippet of computing partial residual for plotting for Shenghan

library(LMMstar) # key library

your_LMM_fit = lmm(your_formula, # your L3 whole brain model or ROI-based analysis model
                   data = your_data) # extracted ROI means, structure it based on your model

your_data$partial_residual <- 
  residuals(your_LMM_fit, type = "partial", 
            variable = c("(Intercept)", 
                         "IOS", "SR")) # your focal (non-control) variable names, change according to your model!
            
## Now you are good to use the new column "partial_residual" 
## to replace your original DV as use ggplot to make figures as usual.

ggplot(your_data, aes(x = SR, y = partial_residual, color = IOS)) + ...


## for example use, see GitHub/srndna-ug/behavioral_analyses/codes/fmri_plots_SANS.Rmd