rm(list=ls())

#--- Fit multiple models using coxph() function
library(dplyr)
library(survAUC)
library(rms)
library(ggplot2)
library(survival)
library(gridExtra)
library(sjPlot)
#library(sjmisc)
#library(sjlabelled)

source("./data/ccoh.data.R") # Data frames defined
ls()


# ----prefix_cum <- "./out/311/coxph-fit-test2"

df_names <- c("ccoh.data") # Datata
 
tvars   <- c("edrel", "rel")
csurv    <- paste0("Surv(",tvars[1],",", tvars[2], ")")       # Do not change this statement
x_cterms <- c("stage", "histol", "age")
cxform <- paste(x_cterms, sep="", collapse="+")               # Do not change this statement
cform   <- paste0(csurv, "~", cxform)
form    <- as.formula(cform)


# Calculate sizes and weights
subcohort_size <- sum(ccoh.data$subcohort)
sampling_fraction <- subcohort_size / total_cohort_size

ccoh.data$Prentice <- ifelse(ccoh.data$subcohort == 1, 1 / sampling_fraction, 1)
range(ccoh.data$Prentice)


#-- clInfo lists for models fitted using coxph function


######
clInfo_coxphx <- list(
  formula     = form,
  data        = as.name("ccoh.data"),
  weights     = "placeholder",
  id          = as.name("seqno"),
  robust      = FALSE
) 

# M1. Prentice weights 
clInfo_coxph1 <- clInfo_coxphx
clInfo_coxph1$weights <- as.name("Prentice")

# Fit the Cox model using weights
M1fit.ccP <- do.call("coxph", clInfo_coxph1  )

# Summarize the model
summary(M1fit.ccP)

## M2. SelfPrentice 
clInfo_coxph2 <- clInfo_coxphx
clInfo_coxph2$weights <- as.name("Prentice")  ## SelfPrentice
M2.ccSP <- do.call("coxph", clInfo_coxph2)


fit_nms <- c("M1fit.ccP", "M2.ccSP")
sapply(fit_nms, function(cnm) coef(eval(parse(text = cnm))))

library(survminer)
ggadjustedcurves(M2.ccSP, variable = 'stage', data = ccoh.data)