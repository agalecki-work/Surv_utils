
rm(list=ls())
source("./R/zzz_Rfuns.R")

# Load Libraries
load_libraries()

# Generate Data (unchanged)
data <- generate_data <- function(n = 100) {
  set.seed(123)
  data <- data.frame(
    id = 1:n,
    ftime = rexp(n, rate = 0.1),  # Follow-up times
    fstatus = sample(0:2, n, replace = TRUE, prob = c(0.3, 0.4, 0.3)),  # 0 = Censored, 1 = Event of interest, 2 = Competing event
    age = sample(50:70, n, replace = TRUE)
  )
  return(data)
}

data <- generate_data(n = 100)    # ftime and fstatus 0:2


# Create Spline Basis for age variable, Variables `age_spline_#` are created
data <- create_spline_basis(data, var_name = "age", df = 4)

# Expand Data Using finegray for event type 1
data <- data %>% mutate(ffstatus = factor(fstatus)) # Create factor 
fg_data <- expand_data_finegray(data, time_var = "ftime", status_var = "ffstatus", etype = 1)

cox_model1 <- coxph(Surv(fgstart, fgstop, fgstatus) ~ age +
                   age_spline_1 + age_spline_2 + age_spline_3 + age_spline_4,
                   data = fg_data)
cox.zph(cox_model1)

# Further Divide Time into Small Intervals Using survSplit
split_data <- split_data_intervals(fg_data, time_start_var = "fgstart", time_stop_var = "fgstop", status_var = "fgstatus", interval_length = 1)

# Create Time-Dependent Covariates
vnms <- paste("age_spline_", 1:4, sep="")
vnms2 <- c("age", vnms)
split_data <- split_data %>%  mutate(time_mid = (fgstart + fgstop) / 2)
split_data <- create_time_dependent_covariates2(split_data, var_names =vnms2 , time_var = "time_mid")

