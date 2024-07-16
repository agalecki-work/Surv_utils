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

source("./data/ccoh.data.R") # Data frames defined
ls()

#---- Objects defined 
# ccoh.data   data.frame
# total_cohort_size

#---- required objects
# ----prefix_cum <- "./out/311/cch-fit-test01"


# fit_devx, fit_valx 

df_names <- c("ccoh.data") # Training data
 
tvars   <- c("edrel", "rel")
csurv    <- paste0("Surv(",tvars[1],",", tvars[2], ")")       # Do not change this statement
x_cterms <- c("stage", "histol", "age")
cxform <- paste(x_cterms, sep="", collapse="+")               # Do not change this statement

cform   <- paste0(csurv, "~", cxform)
form    <- as.formula(cform)


#-- clInfo lists for models fitted using cch function


# Info_cch is a prototype Info list for cch function
clInfo_cchx <- list(
  formula     = form,
  data        = as.name("ccoh.data"),
  subcoh      = ~subcohort, 
  id          = ~seqno,
  stratum     = NULL,             # Argument will be omitted
  cohort.size = total_cohort_size,
  method      = "Prentice",       # "Prentice", "SelfPrentice", "LinYing", "I.Borgan", "II.Borgan"
  robust      = FALSE
) 



##
##------------- Standard case-cohort analysis: simple random subcohort 

## M1. Prentice 
clInfo_cch1 <- clInfo_cchx
M1.ccP <- do.call("cch", clInfo_cch1)

## M2. SelfPrentice 
clInfo_cch2 <- clInfo_cchx
clInfo_cch2$method <-"SelfPrentice"
M2.ccSP <- do.call("cch", clInfo_cch2)

##
##---- (post-)stratified on instit
##

# Define prototype info list
stratsizes <- table(nwtco$instit)

clInfo_cchsx <- clInfo_cchx 
clInfo_cchsx$stratum <- ~instit
clInfo_cchsx$cohort.size <- as.name("stratsizes")

## M3. "I.Borgan"
clInfo_cchs3 <- clInfo_cchsx    #  Prototype list 
clInfo_cchs3$method <- "I.Borgan"

M3.BI <- do.call("cch", clInfo_cchs3)

## M4. "II.Borgan"
clInfo_cchs4 <- clInfo_cchsx    #  Prototype list 
clInfo_cchs4$method <- "II.Borgan"

M4.BII <- do.call("cch", clInfo_cchs4)


fit_nms <- c("M1.ccP", "M2.ccSP", "M3.BI", "M4.BII")

sapply(fit_nms, function(cnm) coef(eval(parse(text = cnm))))

