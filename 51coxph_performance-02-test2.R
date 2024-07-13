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

source("./data/rott_01data.R")


#---- required objects
prefix_cum <- "./out/51/test02"

# fit_devx, fit_valx 

df_names <- c("rott5", "gbsg5")
 
tvars   <- c("ryear", "rfs")
surv    <- paste0("Surv(",tvars[1],",", tvars[2], ")")
x_terms <- c("csize", "nodes2", "nodes3",  "grade3")
cxform <- paste(x_terms, sep="", collapse="+")

cform   <- paste0(surv, "~", cxform)

#-- Info lists
# Infox is a prototype Info list
Infox <- list(
  formula = cform,
  weights = NULL
) 

# Formula evaluated in developmental dataset
ln_bh_formula <- formula(ln_bh ~ I(ryear^-0.5) + I(ryear^-0.5 * log(ryear)))



source("./src/51coxph_performance-02-tmplt.R")

