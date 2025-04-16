regression_test_fun <- 
  function(TR_type_name, TR_ROI_name, model_name, contrast_name, # mostly for figure and component naming (axis, moderator, etc)
           formula_string, focal_var_name, residual_var_input_name){
    
    ### for testing
    # formula_string = formula_list[model_m]
    # focal_var_name = focal_vars_list[[model_m]]
    # residual_var_input_name = residual_var_input_list[model_m]
    ### for testing
    
    ## create temp fit_df of only 1 row to save current model's metrics
    ## reset at the beginning of each model before entering focal var loop
    
    fit_col_names = c("SRxIOSxDP_beta", "SRxIOSxDP_p", "SRxIOSxDP_sig", # start from var columns. model info columns will be add outside the function
                      "SRxIOS_beta", "SRxIOS_p", "SRxIOS_sig", 
                      "SRxDP_beta", "SRxDP_p", "SRxDP_sig", 
                      "SR_beta", "SR_p", "SR_sig",
                      "IOS_beta", "IOS_p", "IOS_sig",
                      "DP_beta", "DP_p", "DP_sig")
    
    fit_df_temp = data.frame(matrix(nrow = 1,
                                    ncol = length(fit_col_names)))
    colnames(fit_df_temp) = fit_col_names
    
    N_sig_focal = 0 # count N of sig focal var. reset at the start of each model loop
    
    ### start of focal N loop
    for (focal_f in 1:length(focal_var_name)) {
      # focal_f = 1
      focal_var_f = focal_var_name[focal_f]
      residual_var_input_name = residual_var_input_name
      current_data_lm = current_data
      
      m_params = model_parameters(model_lm, effects = "fixed")
      
      # find if focal var is significant
      ## find focal var's corresponding columns in fit_df_temp
      focal_var_ind <- which(fit_param_names == focal_var_name)
      focal_var_coef_col_name = fit_param_coef_colnames[focal_var_ind]
      focal_var_p_col_name = fit_param_p_colnames[focal_var_ind]
      focal_var_sig_col_name = fit_param_sig_colnames[focal_var_ind]
      
      fit_df_temp[1, focal_var_coef_col_name] = 
        m_params[m_params$Parameter == focal_var_name, "Coefficient"]
      fit_df_temp[1, focal_var_p_col_name] = 
        m_params[m_params$Parameter == focal_var_name, "p"]
      
      if (m_params[m_params$Parameter == focal_var_name, "p"] < alpha_val) {
        fit_df_temp[1, focal_var_sig_col_name] = "*"
        N_sig_focal = N_sig_focal + 1
      }
      
      #### start of calling partial plot functions
      
      
      
      #### end of calling partial plot functions
    }### end of focal N loop
    return(fit_df_temp[1,])
  }