

######
clInfo_coxphx <- list(
  formula     = form,
  data        = as.name("ccoh.data"),
  weights     = as.name("Prentice"),
  subcoh      = ~subcohort, 
  id          =  seqno,
  stratum     = NULL,
  cohort.size = cohort_size,
  method      = NULL,           
  robust      = FALSE
) 

# Calculate sizes and weights
total_cohort_size <- 4028
subcohort_size <- sum(ccoh.data$subcohort)
sampling_fraction <- subcohort_size / total_cohort_size

# Assign weights
ccoh.data$Prentice <- ifelse(ccoh.data$subcohort == 1, 1 / sampling_fraction, 1)
range(ccoh.data$Prentice)


# Fit the Cox model using weights
fit.ccP <- coxph(Surv(edrel, rel) ~ stage + histol + age, data = ccoh.data, weights = )

# Summarize the model
summary(fit.ccP)


# source("./src/21-cch-fit-tmplt.R")

