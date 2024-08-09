SurvSplit2_truncate <- function(df, tvars, time_horizon, postfix = character(0)){
 
 #csurv <- paste0("Surv(", tvars[1], ",",  tvars[2], ")") # Surv(time, status)
 
 # Apply time horizon limit to the data frame
 
 nm1 <- paste0(tvars[1], postfix)
 nm2 <- paste0(tvars[2], postfix)

 df[, nm1]  <- pmin  (df[, tvars[1]], time_horizon)
 df[, nm2]  <- ifelse(df[, tvars[1]] > time_horizon, 0, df[, tvars[2]])

 # Create the original and adjusted Surv objects
 # df[, nm1] <- with(df, Surv(eval(as.name(tvars[1])), eval(as.name(tvars[2])) , type = "mstate"))
 # df[, nm2] <- with(df, Surv(adjusted_time, adjusted_status, type = "mstate" ))
return(df)
}

# SurvSplit2_truncate (dfin_datax, tvars_vec, tm_cut)

