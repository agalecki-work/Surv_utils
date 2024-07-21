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

# Mandatory list `dfAll_info`
dfAll_Info <- list(
   current_folder = current_folder,
   datain_script   = "001cric_olinknpx_112023_v1_imputed0",  # R script that creates data frames 
   datain_basename = "001cric_olinknpx_112023_v1_imputed0",
   datain_extension = "datain_extension", 
   dfnms_all   = c("cric_imputed"),  # Data frames created by this script
   df_name     = "Place holder", # One or two data frames (training and/or validation) selected
   id          = "PID",
   tvars_all   = tvars_all,    # Matrix with  variables' names used to create Surv objects
   time_horizon = 10, 
   CCH_data    = FALSE
)
rm(current_folder, datain_basename, datain_extension, tvars_all)
print(dfAll_Info)
