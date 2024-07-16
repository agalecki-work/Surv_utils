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
library(survminer)

source("./data/ccoh.data.R") # Data frames defined
ls()

#---- Objects defined 
# ccoh.data   data.frame

subco_data <- ccoh.data %>% filter(subcohort == 1)   

#---- required objects
# ----prefix_cum <- "./out/111/ccoh-coxph-test01"


# fit_devx, fit_valx 

df_name <- c("subco_data") # simple random sample data 
 
tvars   <- c("edrel", "rel")
csurv    <- paste0("Surv(",tvars[1],",", tvars[2], ")")       # Do not change this statement
x_cterms <- c("stage", "histol", "age")
cxform <- paste(x_cterms, sep="", collapse="+")               # Do not change this statement

cform   <- paste0(csurv, "~", cxform)
form    <- as.formula(cform)


#-- clInfo list for a models fitted using cch function


# Info_cch is a prototype Info list for cch function
clInfo_coxph <- list(
  formula     = form,
  data        = as.name(df_name),
  id          = as.name("seqno"),
  robust      = TRUE
) 

coxph_fit <- do.call("coxph", clInfo_coxph)
coxph_fit 
coef(coxph_fit)


# Adjusted Survival Curves for Cox Proportional Hazards Model

clInfo_ggadjcurves <- list(
      fit = as.name("coxph_fit"),
      variable = 'stage',    # Grouping variable 
      data = as.name(df_name)
)

       
ggadjustedcurves(M2.ccSP, variable = 'stage', data = ccoh.data)


