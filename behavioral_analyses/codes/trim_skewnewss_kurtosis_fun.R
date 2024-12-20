# Function to trim for target kurtosis
trim_for_skewness_fun <- function(raw_vector) {
  ### for testing
  # raw_vector = sub_i_fit$alpha_i
  # raw_vector = sub_i_fit$alpha_i
  # raw_vector = sub_i_fit$epsilon_i
  ###
  # target_kurtosis = 0
  target_skew = 0
  # target_skew = 0
  tolerance = 0.001
  trim_step_min = 1
  ###
  
  sorted_vector = sort(raw_vector)
  
  n <- length(raw_vector)
  lower_bound <- 1
  upper_bound <- n
  
  skewness_val = skewness(sorted_vector)  # calculate skewness
  kurtosis_val = kurtosis(sorted_vector)  # calculate kurtosis
  print(c(skewness_val, kurtosis_val))
  
  while (TRUE) {
    trimmed_vector <- sorted_vector[lower_bound:upper_bound]
    
    current_kurtosis <- kurtosis(trimmed_vector)
    distance_kurtosis_target = abs(current_kurtosis - target_kurtosis)

    current_skewness <- skewness(trimmed_vector)
    distance_skewness_target = abs(abs(current_skewness) - target_skew)
    
    print(sprintf("skewness = %.2f, kurtosis = %.2f", 
                  current_skewness, current_kurtosis))
    
    if (distance_skewness_target <= tolerance) {
      break
    }
    # first trim skewness
    ###
    if (current_skewness < 0 & current_skewness < -target_skew) {
      lower_bound <- lower_bound + trim_step
      upper_bound <- upper_bound
    } else if (current_skewness > 0 & current_skewness > target_skew) {
      lower_bound <- lower_bound
      upper_bound <- upper_bound - trim_step
    } else {
      break
    }
    ###
    if (lower_bound >= upper_bound) break
  }
  histogram(trimmed_vector)
  return(median(trimmed_vector))
}