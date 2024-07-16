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
prefix_cum <- "./out/151/test02"

df_names <- c("rott5", "gbsg5") # Development and validation data frame names

tvars   <- c("ryear", "rfs")    # Time and status variable names
csurv    <- paste0("Surv(",tvars[1],",", tvars[2], ")")
x_cterms <- c("csize", "nodes2", "nodes3",  "grade3")

# Formula evaluated in developmental dataset
ln_bh_formula <- formula(ln_bh ~ I(ryear^-0.5) + I(ryear^-0.5 * log(ryear)))

source("./src/151-coxph_performance-02-tmplt.R")

