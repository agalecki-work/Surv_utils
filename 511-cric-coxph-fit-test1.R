rm(list=ls())

source("./R/zzz_Rfuns.R")

data_path <- "./data/"

require(dplyr)

source("./data/cric_olinknpx_112023_v1_imputed0.R") # Data frame `cric_imputed` defined
ls()
rm(data_path, Paths_info, Rdata_path)

#--- Objects available
#  "cric_imputed" "Rdata_name"

df_name <- "cric_imputed"
time_horizon <- 10  # 10 years
tm_cut       <- 9.99

# Select tvars:

tvars1 <- c("TIME_ESRD", "ESRD")
tvars2 <- c("TIME_LOSS50", "LOSS50")
tvars3 <- c("TIME_LOSS50_ESRD", "LOSS50_ESRD")
tvars4 <- c("TIME_DEATH", "DEAD")
tvars_all <- rbind(tvars1, tvars2, tvars3, tvars4)
colnames(tvars_all) <- c("timevar", "eventvar")
tvars_all 
tvars <- tvars1                    #  <---- select tvars


# Before truncating time in `cric_imputed` df
rngs <-  sapply(tvars_all[,1], FUN =  function(tmx){
         timex <-  cric_imputed[, tmx]
         range(timex)
 })
rngs

tbls <-  sapply(tvars_all[,2], FUN =  function(evnt){
         event <-  cric_imputed[, evnt]
         table(event)
 })
tbls



cric_imputed1 <- SurvSplit_truncate(cric_imputed, tvars1, tm_cut)
cric_imputed2 <- SurvSplit_truncate(cric_imputed1, tvars2, tm_cut)
cric_imputed3 <- SurvSplit_truncate(cric_imputed2, tvars3, tm_cut)
cric_imputed4 <- SurvSplit_truncate(cric_imputed3, tvars4, tm_cut)

rm(cric_imputed1, cric_imputed2, cric_imputed3)   

# After truncating time

rngs_after <-  sapply(tvars_all[,1], FUN =  function(tmx){
         timex <-  cric_imputed4[, tmx]
         range(timex)
 })
rngs_after

tbls_after <-  sapply(tvars_all[,2], FUN =  function(evnt){
         event <-  cric_imputed4[, evnt]
         table(event)
 })
tbls_after




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


