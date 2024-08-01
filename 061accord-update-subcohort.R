
# source("061accord-update-subcohort.R") # This file

rm(list= ls())

#--- Create 'initInfo' lists and 'dfin1_name' dataframe
source("060accord_olink_analytical_dataset040323.R") 
require(survival)
#print(df_initInfo)
#print(dfCCH_initInfo)


#---- Create `df_info` list by modifying  `df_initInfo`  ---------
#-- Notes: 

#  1. `dfin2_name` is empty: Data for external validation NOT selected
#  2. `CCH_data` is FALSE: CCH data will not be created
#  3. `cfilter` Subcohort in  `dfin1_name` selected
#  4. `dfin1_name` has two elements .  

df_Info     <- df_initInfo         # Copy initInfo list

df_Info$cfilter <- "SUBCO15 == 1 & FEMALE ==1"  # Subcohort only

df_Info$CCH_data    <- NULL    #!!!!

df_Info$dfin1_name[2] <- "accord_subcohort" # original and new name
df_Info$cfilter_comment <- "Females in subcohort only"
df_Info$time_horizon <- c(10, 9.99)  # 10 years, if vector with two elements use second element to define tm_cut (Inf no truncation)

# print(df_Info)

# dfCCH_Info  will be set to NULL, because CCH_data = FALSE 
source("./src/add_aux_vars.R")

keep_objects <- c("accord", "accord_subcohort", "df_Info")

# Cleanup (No changes below) 
ls_objects <- ls()
rm_objects  <- c(setdiff(ls_objects, keep_objects), "ls_objects")
#rm(list = rm_objects)
rm(rm_objects)
