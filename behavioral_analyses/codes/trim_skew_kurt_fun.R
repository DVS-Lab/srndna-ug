# created on 12/19/2024 by Jen Yang
# last modified on 12/19/2024 by Jen Yang

trim_skew_kurt <- function(vector, trim_step = 1, skew_threshold = 0.5, kurt_threshold = 3) {
  ### for testing
  vector = NA
  ###
  
  skew_val = e1071::skewness(vector)  # calculate skewness
  kurt_val = e1071::kurtosis(vector)  # calculate kurtosis
  
  # Initialize trimming percentiles
  lower_trim <- trim_step
  upper_trim <- trim_step
  
  # Adjust for skewness
  if(skew_val > skew_threshold) {
    # Right-skewed: trim more from right
    lower_trim <- trim_step
    upper_trim <- trim_step*2
  } else if(skew_val < -skew_threshold) {
    # Left-skewed: trim more from left
    lower_trim <- trim_step*2
    upper_trim <- trim_step
  }
  
  # Further adjust for high kurtosis
  if(kurt_val > kurt_threshold) {
    lower_trim <- lower_trim + trim_step
    upper_trim <- upper_trim + trim_step
  }
  
  # Apply trimming
  lower_bound <- quantile(vector, lower_trim/100)
  upper_bound <- quantile(vector, 1 - upper_trim/100)
  
  trimmed_vector <- vector[vector >= lower_bound & vector <= upper_bound]
  
  # calculate skew and kurt for trimmed vector
  trimmed_skew_val = e1071::skewness(trimmed_vector)  # calculate skewness
  trimmed_kurt_val = e1071::kurtosis(trimmed_vector)  # calculate kurtosis
  
  return(c(trimmed_skew_val, trimmed_kurt_val, trimmed_vector))
}

}
