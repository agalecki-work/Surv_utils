create_initSplit <- function(data, initSplitx){
  if (length(initSplitx) == 0){
     data <- data %>% mutate(initSplit = 1)
  } else {
     tt <- initSplitx
     tmp <-  sample(c(0,1),size = nrow(data), replace=TRUE,prob =c(1-tt,tt))
     data$initSplit <- tmp
  }
  return(data)
} 
