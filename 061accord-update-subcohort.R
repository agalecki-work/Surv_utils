
#source("061accord-update-subcohort.R") # This file

rm(list= ls())

source("060accord_olink_analytical_dataset040323.R") 
require(survival)
#print(df_initInfo)
#print(dfCCH_initInfo)


#---- Input Info modified (if needed)  ---------
df_Info     <- df_initInfo

df_Info$cfilter <- "SUBCO15 == 1"  # Subcohort only

df_Info$cfilter_comment <- "Subcohort only"
df_Info$time_horizon <- 10  # 10 years, if vector with two elements use second element to define tm_cut (Inf no truncation)
df_Info$CCH_data    <- FALSE    #!!!!

# print(df_Info)

# dfCCH_Info <- dfCCH_Info 
dfCCH_Info <- "This is placeholdr, CCH_data = FALSE, `dfCCH_Info` list is not created" 
source("./src/add_aux_vars.R")

keep_objects <- c("accord", "df_initInfo", "dfCCH_initInfo", dfout_name)

# Cleanup (No changes below) 
ls_objects <- ls()
rm_objects  <- c(setdiff(ls_objects, keep_objects), "ls_objects")
rm(list = rm_objects)
rm(rm_objects)
