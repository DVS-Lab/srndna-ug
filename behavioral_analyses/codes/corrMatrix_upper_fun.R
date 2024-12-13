corrMatrix_upper_fun = function(data_df) {

# only construct pearson's correlation heat map for upper triangle
  
## calculate the correlation matrix
cormatrix_data = rcorr(as.matrix(data_df), type='pearson')
# cormatrix_data = rcorr(as.matrix(data_df), type="spearman")
### r
full_cormatrix_r_data = cormatrix_data$r

full_cormatrix_r_data[upper.tri(full_cormatrix_r_data)] =
  cormatrix_data$r[upper.tri(cormatrix_data$r)]

full_cormatrix_r_data[lower.tri(full_cormatrix_r_data)] = NA

full_cormatrix_r_data = melt(full_cormatrix_r_data)

### p
full_cormatrix_p_data = cormatrix_data$P

full_cormatrix_p_data[upper.tri(full_cormatrix_p_data)] =
  cormatrix_data$P[upper.tri(cormatrix_data$P)]

full_cormatrix_p_data[lower.tri(full_cormatrix_p_data)] = NA

full_cormatrix_p_data = melt(full_cormatrix_p_data)

### r for color
full_cormatrix_r_color_data = cormatrix_data$r

full_cormatrix_r_color_data[upper.tri(full_cormatrix_r_color_data)] =
  cormatrix_data$r[upper.tri(cormatrix_data$r)]

full_cormatrix_r_color_data[lower.tri(full_cormatrix_r_color_data)] = 0

full_cormatrix_r_color_data = melt(full_cormatrix_r_color_data)

full_cormatrix_r_data$sigP = full_cormatrix_p_data$value
full_cormatrix_r_data$sigR = full_cormatrix_r_data$value
full_cormatrix_r_data$sigR[full_cormatrix_r_data$sigP >= 0.05] <- NA
full_cormatrix_r_data$sigP[full_cormatrix_r_data$sigP >= 0.05] <- NA
full_cormatrix_r_data$sigR = round(full_cormatrix_r_data$sigR, 4)
full_cormatrix_r_data$sigR_color = full_cormatrix_r_color_data$value
full_cormatrix_r_data$sigR_color[is.na(full_cormatrix_r_data$sigP) & full_cormatrix_r_color_data$value !=0 ] = NA
full_cormatrix_r_data$sigR_color[full_cormatrix_r_color_data$value == 1 ] = 1

return(full_cormatrix_r_data)
}