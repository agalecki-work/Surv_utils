rm(list=ls())

library(dplyr)
library(survAUC)
library(rms)
library(ggplot2)
library(survival)
library(gridExtra)
library(sjPlot)
#library(sjmisc)
#library(sjlabelled)

source("./data/rott_02data.R")


#---- required objects
prefix_cum <- "./out/151/test01"
 

df_names <- c("df_dev", "df_val") # Development and validation data frame names
 
tvars   <- c("rfstime", "status") # Time and status variable names
x_cterms <- c("I(age^3)", "I(age^3 * log(age))", "meno", "factor(size)",
           "I((nodes)^-0.5)", "er", "hormon")

# Formula to be evaluated in developmental dataset (Most likely it is data specific)
ln_bh_formula <- formula(ln_bh ~ I(rfstime^-0.5) + I(rfstime^-0.5 * log(rfstime)))
           
source("./src/151-coxph_performance-02-tmplt.R")



