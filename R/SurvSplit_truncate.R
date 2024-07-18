SurvSplit_truncate <- function(data, tvars, tm_cut){

# Apply  survSplit to `time` variable
  csurv <- paste0("Surv(", tvars[1], ",",  tvars[2], ")")
  cform <- paste0 (csurv, " ~ .")
  temp <- survSplit(as.formula(cform), data = data, cut = tm_cut, episode = "epsd")
  data1 <- temp %>% 
           filter(epsd == 1) %>%            # Select first row from each episode group, 
           select(-c(tstart, epsd))         # variable tstart =0 is dropped
  return(data1)
}
