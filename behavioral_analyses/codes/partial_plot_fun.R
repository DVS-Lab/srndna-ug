partial_plot_fun = 
  function(TR_type_name, TR_ROI_name, model_name, contrast_name, # mostly for figure and component naming (axis, moderator, etc)
           formula_string, focal_var_name, residual_var_input_name,
           current_data_lm) {
    
    LMM_df = current_data_lm
    formula_LMM = as
    
    pres_LLM = lmm(TR_brain ~ SR_brain * IOS_brain + DP, data = LLM_df) # I'll need to reuse the lm() formula
    LLM_df$pres <- residuals(pres_LLM, type = "partial", 
                             variable = c("(Intercept)","SR_brain","IOS_brain")) # a list of focal variables
    head(LLM_df) #
    
    if (N_sig_focal ) {
      ## ggplot with facet for model m_TwoWay_IOS_DP
    } else {
      ## conventional moderation ggplot
    }
    return()
  }