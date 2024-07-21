## source("010cric_olinknpx_112023_v1_imputed0.R")

rm(list =ls())


require(dplyr)

# STEP 1: Create data frames
current_folder <-  getwd()
datain_basename <- "cric_olinknpx_112023_v1_imputed0" # Without extension
datain_extension <- "Rdata"

load(paste0(current_folder, "/data/", datain_basename, ".", datain_extension), verbose=TRUE)

cric_imputed <- dtx_imputed0
rm(dtx_imputed0, Paths_info) # not needed


tvars1 <- c("TIME_ESRD", "ESRD")             #  Variables' names used to create Surv objects
tvars2 <- c("TIME_LOSS50", "LOSS50")
tvars3 <- c("TIME_LOSS50_ESRD", "LOSS50_ESRD")
tvars4 <- c("TIME_DEATH", "DEAD")          # Competing risk (if any) included in the last row of `tvars_all` matrix

tvars_all <- rbind(tvars1, tvars2, tvars3, tvars4)
colnames(tvars_all) <- c("timevar", "eventvar")
tvars_all 

rm(tvars1, tvars2, tvars3, tvars4)           # Cleanup

# Mandatory (template) list `dfAll_info`
dfAll_Info <- list(
   current_folder = current_folder,
   datain_script   = "001cric_olinknpx_112023_v1_imputed0",  # R script (this file) that creates data frames 
   datain_basename = datain_basename,
   datain_extension = datain_extension, 
   dfnms_all       = "cric_imputed",     # Data frames created by this script
   dfin_name       = "cric_imputed",     # Note: Two data frames, if external validation 
   CCH_data        = FALSE,              # Case-cohort data
   id              = "PID",
   cfilter         = character(0),  # string with filter stmnt 
   time_horizon    = c(10,9.99),    # Second element used as a cut-off 
   initSplit       = 0.8,
   nfolds          = 10,
   tvars_all       = tvars_all      # Matrix (two columns) with  variables' names used to create Surv objects
)
rm(current_folder, datain_basename, datain_extension, tvars_all)
message("--- print(dfAll_Info)")
# print(dfAll_Info)
