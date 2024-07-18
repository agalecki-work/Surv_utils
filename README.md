# Surv_utils

# Datasets 

The `./data` subfolder contains R scripts that generate various datasets

##  `rott_01data.R`

[Link with details](https://github.com/danielegiardiello/Prediction_performance_survival/blob/main/01_predsurv_minimal.R)

Input: 

* `survival::rotterdam`
* `survival::gbsg`

Output:

* `rott5` Training/developmental dataset 
* `gbsg5` External validation dataset 

Notes: 

* `Surv(ryear, rfs)` (time horizon is set at 5 years)
* Variables used in `Surv(ryear, rfs)` were derived by treating death as a censoring event
 

##  `rott_02data.R`

[Link with details](https://missingdatasolutions.rbind.io/2021/02/cox-external-validation/)


Input: 

* `survival::rotterdam`
* `survival::gbsg`

Output:

* `df_dev` Training/developmental dataset 
* `df_val` External validation dataset 

Notes: 

* Surv(rfstime, status) (time horizon set at 7 years)
* Variables used in `Surv(rfstime, status)` were derived by treating death as a censoring event 
   using the code below:

```
df_dev$rfstime <- pmin(df_dev$rtime, df_dev$dtime) # determine outcome
df_dev$status  <- pmax(df_dev$recur, df_dev$death)
df_dev$rfstime <- df_dev$rfstime/365    # convert time to years
df_dev$status[df_dev$rfstime >= 7] <- 0 # censor events after 7 years
df_dev$rfstime[df_dev$rfstime > 7] <- 7 # truncate survival time at 7 years
```   


#  Scripts in the main folder

Scripts are divided into four groups. 

* SRS stands for  simple random sample.
* C-C stands for data from Case-Cohort Study

## 1xx:  SRS data: Cox model

with time, status (0,1) variables


## 2xx:  SRS data: Competing Risks 

with time, status (0,1,2) variables

## 3xx:  C-C data: Cox model

Case-cohort study with time, status (0,1) variables 

`total_cohort_size`
df from case cohort study
`subcohort` indicator variable in `ccoh.data`

## 4xx:  C-C data: Competing Risks 


Case-cohort study for competing risks model , with time, status (0,1,2) variables