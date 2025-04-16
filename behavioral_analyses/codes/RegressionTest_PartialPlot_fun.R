

LLM_df = current_data_lm
LLM_df$IOS_brain = as.factor(LLM_df$IOS_brain)


pres_LLM = lmm(TR_brain ~ SR_brain * IOS_brain + DP, data = LLM_df) # I'll need to reuse the lm() formula
LLM_df$pres <- residuals(pres_LLM, type = "partial", 
                         variable = c("(Intercept)","SR_brain","IOS_brain")) # a list of focal variables
head(LLM_df) #

