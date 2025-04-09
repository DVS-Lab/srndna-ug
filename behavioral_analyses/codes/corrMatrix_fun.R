corrMatrix_fun = function(study0_data_select_std) {

## calculate the correlation matrix
cormatrix_study0 = rcorr(as.matrix(study0_data_select_std), type='pearson')

## extract r and construct lower triangle
cormatrix_r_lower_study0 = cormatrix_study0$r
cormatrix_r_lower_study0[lower.tri(cormatrix_r_lower_study0)] <- NA
cormatrix_r_lower_study0 = melt(cormatrix_r_lower_study0)

## extract P value and construct lower triangle
cormatrix_p_lower_study0 = cormatrix_study0$P
cormatrix_p_lower_study0[lower.tri(cormatrix_p_lower_study0)] <- NA
cormatrix_p_lower_study0 = melt(cormatrix_p_lower_study0)
cormatrix_p_lower_study0$value[cormatrix_p_lower_study0$value >= 0.05] <- NA

cormatrix_rp_study0 = cormatrix_r_lower_study0
cormatrix_rp_study0$sigP  = round(cormatrix_p_lower_study0$value, digits = 4)

## partial correlation
study0_data_select_std_full = na.omit(study0_data_select_std)
pcormatrix_study0 = pcor(study0_data_select_std_full, method = 'pearson')

## extract r and construct upper triangle
pcormatrix_r_upper_study0 = pcormatrix_study0$estimate
pcormatrix_r_upper_study0[upper.tri(pcormatrix_r_upper_study0)] <- NA
pcormatrix_r_upper_study0 = melt(pcormatrix_r_upper_study0)

## extract P value and construct upper triangle
pcormatrix_p_upper_study0 = pcormatrix_study0$p.value
pcormatrix_p_upper_study0[upper.tri(pcormatrix_p_upper_study0)] <- NA
pcormatrix_p_upper_study0 = melt(pcormatrix_p_upper_study0)
pcormatrix_p_upper_study0$value[pcormatrix_p_upper_study0$value >= 0.05] <- NA

pcormatrix_rp_study0 = pcormatrix_r_upper_study0
pcormatrix_rp_study0$sigP  = round(pcormatrix_p_upper_study0$value, 4)

## upper triangle - corr; lower triangle - partial corr
### r
full_cormatrix_r_study0 = pcormatrix_study0$estimate

full_cormatrix_r_study0[upper.tri(full_cormatrix_r_study0)] =
  cormatrix_study0$r[upper.tri(cormatrix_study0$r)]

full_cormatrix_r_study0[lower.tri(full_cormatrix_r_study0)] = 
  pcormatrix_study0$estimate[lower.tri(pcormatrix_study0$estimate)]

full_cormatrix_r_study0 = melt(full_cormatrix_r_study0)

### p
full_cormatrix_p_study0 = pcormatrix_study0$p.value

full_cormatrix_p_study0[upper.tri(full_cormatrix_p_study0)] =
  cormatrix_study0$P[upper.tri(cormatrix_study0$P)]

full_cormatrix_p_study0[lower.tri(full_cormatrix_p_study0)] = 
  pcormatrix_study0$p.value[lower.tri(pcormatrix_study0$p.value)]

full_cormatrix_p_study0 = melt(full_cormatrix_p_study0)

full_cormatrix_r_study0$sigP = full_cormatrix_p_study0$value
full_cormatrix_r_study0$sigR = full_cormatrix_r_study0$value
full_cormatrix_r_study0$sigR[full_cormatrix_r_study0$sigP >= 0.05] <- NA
full_cormatrix_r_study0$sigP[full_cormatrix_r_study0$sigP >= 0.05] <- NA
full_cormatrix_r_study0$sigR = round(full_cormatrix_r_study0$sigR, 4)

return(full_cormatrix_r_study0)
}