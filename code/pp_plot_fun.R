pp_plot_fun = function(computer_fit) {
  # Extract predicted values
  y_pred_mean <- apply(computer_fit$parVals$y_pred, c(2,3), mean)
  y_pred_mean = data.frame(y_pred_mean)
  y_pred_mean$subjID = 1:nrow(y_pred_mean)
  
  # Extract actual data
  numSubjs = dim(computer_fit$allIndPars)[1] # number of subjects
  subjList = unique(computer_fit$rawdata$subjID) # list of subject IDs
  maxT = max(table(computer_fit$rawdata$subjID)) # maximum number of trials
  true_y = array(NA, c(numSubjs, maxT)) # true data (`true_y`)
  true_y = data.frame(true_y)
  true_y$subjID = 1:nrow(true_y)
  
  # Fill true_y with actual choice data for each subject
  for (i in 1:numSubjs) {
    i
    tmpID = subjList[i]
    tmpData = subset(computer_fit$rawdata, subjID == tmpID)
    true_y[i, 1:nrow(tmpData)] = tmpData$accept # only for data with a 'choice' column
  }
  
  # plot true and predicted data
  y_pred_mean_long <- melt(y_pred_mean, 
                  id.vars = c("subjID"),  # Columns to keep as is
                  variable.name = "Trial_N",  # Name for the new variable column
                  value.name = "Choice")  # Name for the new value column
  y_pred_mean_long$type = "predicted"
  
  true_y_long <- melt(true_y, 
                           id.vars = c("subjID"),  # Columns to keep as is
                           variable.name = "Trial_N",  # Name for the new variable column
                           value.name = "Choice")  # Name for the new value column
  true_y_long$type = "true"
  
  pred_data_all = rbind(true_y_long, y_pred_mean_long)
  
  ggplot(pred_data_all, aes(x = subjID, y = Choice, color = type)) +
    geom_point()
}
