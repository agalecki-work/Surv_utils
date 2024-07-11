# rm(list = ls())

# source("rott_02data.R")

require(dplyr)
require(survival)


#=========================  Data rotterdam (2) =================
#  https://missingdatasolutions.rbind.io/2021/02/cox-external-validation/
  
# Train/development data

df_dev <- survival::rotterdam # assign rotterdam data to development dataset
df_dev <- subset(df_dev, nodes>0) # select patients with positive nodes
df_dev$rfstime <- pmin(df_dev$rtime, df_dev$dtime) # determine outcome
df_dev$status  <- pmax(df_dev$recur, df_dev$death)

df_dev$rfstime <- df_dev$rfstime/365 # convert time to years
df_dev$status[df_dev$rfstime>=7] <- 0 # censor events after 7 years (84 months)

df_dev$rfstime[df_dev$rfstime>7] <- 7 # truncate survival time at 7 years

df_dev$size <- factor(df_dev$size) # define variables
df_dev$age  <- df_dev$age/100
df_dev$er   <- df_dev$er/1000


# Validation/testing data (2)
df_val <- survival::gbsg # validation data

df_val$size <- factor(cut(df_val$size, breaks = c(0, 20, 50, 125), labels = c(1,2,3)))
df_val$age <- df_val$age/100
df_val$er <- df_val$er/1000
df_val$rfstime <- df_val$rfstime/365 # convert to years

