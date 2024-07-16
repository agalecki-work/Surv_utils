# Surv_utils

# Datasets 

The `./data` subfolder contains R scripts that generate various datasets

##  `rott_01data.R`

Input: 

* https://github.com/danielegiardiello/Prediction_performance_survival/blob/main/01_predsurv_minimal.R
* `survival::rotterdam` (training)
* `survival::gbsg` (external validation)

Output:

* `rott5` Training dataset 
* `gbsg5` Validation dataset 
* Note: Surv(ryear, rfs) (time horizon at 5 years)
* Variables used in `Surv(ryear, rfs)` were derived by treating death as a censoring event
 

##  `rott_02data.R`

Input: 

* https://missingdatasolutions.rbind.io/2021/02/cox-external-validation/
* `survival::rotterdam`
* `survival::gbsg`

Output:

* `df_dev` Training/developmental dataset (survival time truncated at 7 years)
* `df_val` Validation dataset (survival time truncated at 7 years)
* Notes: 
   -Surv(rfstime, status) (time horizon at 7 years)
   - Variables used in `Surv(rfstime, status)` were derived by treating death as a censoring event 
   using the code below:

```
df_dev$rfstime <- pmin(df_dev$rtime, df_dev$dtime) # determine outcome
df_dev$status  <- pmax(df_dev$recur, df_dev$death)
df_dev$rfstime <- df_dev$rfstime/365    # convert time to years
df_dev$status[df_dev$rfstime >= 7] <- 0 # censor events after 7 years
df_dev$rfstime[df_dev$rfstime > 7] <- 7 # truncate survival time at 7 years
```   


##  Scripts in main folder

Scripts are divided into four groups. 

* 1xx  Simple random sample with time, status (0,1) variables
* 2xx  Simple random sample for competing risks model with time, status (0,1,2) variables
* 3xx  Case-cohort study with time, status (0,1) variables 
# `total_cohort_size`
# df from case cohort study
# `subcohort` indicator variable in `ccoh.data`

* 4xx  Case-cohort study for competing risks model , with time, status (0,1,2) variables