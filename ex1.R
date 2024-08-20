library(survival)
library(dplyr)
library(splines)
library(cmprisk)

# Generate example data
set.seed(123)
n <- 100
data <- data.frame(
  id = 1:n,
  ftime = rexp(n, rate = 0.1),  # Follow-up times
  fstatus = sample(0:2, n, replace = TRUE, prob = c(0.3, 0.4, 0.3)),  # 0 = Censored, 1 = Event of interest, 2 = Competing event
  age = sample(50:70, n, replace = TRUE)
)

# Create spline basis for the age covariate
age_spline <- bs(data$age, df = 4)

# Add spline basis functions to the dataset
spline_cols <- as.data.frame(age_spline)
colnames(spline_cols) <- paste0("age_spline_", 1:ncol(spline_cols))
data <- cbind(data, spline_cols)

# Expand the data using finegray() for the event of interest (status = 1)
data$fstatus <- factor(data$fstatus)
fg_data <- finegray(Surv(ftime, fstatus) ~ ., data = data, etype = 1)


cox_model1 <- coxph(Surv(fgstart, fgstop, fgstatus) ~ 
                   age_spline_1 + age_spline_2 + age_spline_3 + age_spline_4,
                   data = fg_data)
cox.zph(cox_model1)


# Use survSplit to divide time into smaller intervals
interval_length <- 1
split_data <- survSplit(Surv(fgstart, fgstop, fgstatus) ~ ., data = fg_data, cut = seq(0, max(fg_data$fgstop), by = interval_length))

# Create time-dependent covariates by interacting time with spline basis functions
split_data <- split_data %>%
  mutate(time = (fgstart + fgstop) / 2,  # Midpoint of the interval
         age_spline_1_time = age_spline_1 * time,
         age_spline_2_time = age_spline_2 * time,
         age_spline_3_time = age_spline_3 * time,
         age_spline_4_time = age_spline_4 * time)

# Fit the Cox proportional hazards model using the expanded dataset
cox_model <- coxph(Surv(fgstart, fgstop, fgstatus) ~ 
                   age_spline_1 + age_spline_2 + age_spline_3 + age_spline_4 +
                   age_spline_1_time + age_spline_2_time + age_spline_3_time + age_spline_4_time, 
                   data = split_data)

# Summarize the model
summary(cox_model)