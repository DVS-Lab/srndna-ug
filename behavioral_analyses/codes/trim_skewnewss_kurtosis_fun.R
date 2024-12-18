library(moments)  # for kurtosis and skewness calculations

# Function to trim for target kurtosis
trim_for_kurtosis <- function(data, target_kurtosis = 1.8, tolerance = 0.05) {
  sorted_data <- sort(data)
  n <- length(data)
  lower_bound <- 1
  upper_bound <- n
  
  while (TRUE) {
    trimmed_data <- sorted_data[lower_bound:upper_bound]
    current_kurtosis <- kurtosis(trimmed_data)
    
    if (abs(current_kurtosis - target_kurtosis) <= tolerance) {
      break
    }
    
    if (current_kurtosis > target_kurtosis) {
      lower_bound <- lower_bound + 1
      upper_bound <- upper_bound - 1
    } else {
      break
    }
    
    if (lower_bound >= upper_bound) break
  }
  return(trimmed_data)
}

# Function to trim for target skewness
trim_for_skewness <- function(data, target_skewness = 0, tolerance = 0.05) {
  sorted_data <- sort(data)
  n <- length(data)
  lower_bound <- 1
  upper_bound <- n
  
  while (TRUE) {
    trimmed_data <- sorted_data[lower_bound:upper_bound]
    current_skewness <- skewness(trimmed_data)
    
    if (abs(current_skewness - target_skewness) <= tolerance) {
      break
    }
    
    if (current_skewness > target_skewness) {
      lower_bound <- lower_bound + 1
      upper_bound <- upper_bound - 1
    } else {
      break
    }
    
    if (lower_bound >= upper_bound) break
  }
  return(trimmed_data)
}

# Apply sequential trimming
trimmed_kurtosis <- trim_for_kurtosis(your_data)
trimmed_both <- trim_for_skewness(trimmed_kurtosis)

# Visualize results
library(ggplot2)
library(gridExtra)

p1 <- ggplot(data.frame(x = your_data), aes(x = x)) +
  geom_histogram(bins = 30, fill = "skyblue", color = "black") +
  ggtitle(paste("Original Distribution\n",
                "Kurtosis:", round(kurtosis(your_data), 2),
                "Skewness:", round(skewness(your_data), 2))) +
  theme_minimal()

p2 <- ggplot(data.frame(x = trimmed_kurtosis), aes(x = x)) +
  geom_histogram(bins = 30, fill = "lightgreen", color = "black") +
  ggtitle(paste("Trimmed for Kurtosis\n",
                "Kurtosis:", round(kurtosis(trimmed_kurtosis), 2),
                "Skewness:", round(skewness(trimmed_kurtosis), 2))) +
  theme_minimal()

p3 <- ggplot(data.frame(x = trimmed_both), aes(x = x)) +
  geom_histogram(bins = 30, fill = "lightcoral", color = "black") +
  ggtitle(paste("Trimmed for Both\n",
                "Kurtosis:", round(kurtosis(trimmed_both), 2),
                "Skewness:", round(skewness(trimmed_both), 2))) +
  theme_minimal()

grid.arrange(p1, p2, p3, ncol = 3)
