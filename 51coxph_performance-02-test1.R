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
prefix_cum <- "./out/51/test01"

# fit_devx, fit_valx 

df_names <- c("df_dev", "df_val")
 
tvars   <- c("rfstime", "status")
surv    <- paste0("Surv(",tvars[1],",", tvars[2], ")")
x_terms <- c("I(age^3)", "I(age^3 * log(age))", "meno", "factor(size)",
           "I((nodes)^-0.5)", "er", "hormon")
cxform <- paste(x_terms, sep="", collapse="+")

cform   <- paste0(surv, "~", cxform)

#-- Info lists
# Infox is a prototype Info list
Infox <- list(
  formula = cform,
  weights = NULL
) 

# Formula evaluated in developmental dataset
ln_bh_formula <- formula(ln_bh ~ I(rfstime^-0.5) + I(rfstime^-0.5 * log(rfstime)))



source("./src/51coxph_performance-02-tmplt.R")

