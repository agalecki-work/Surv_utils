
#  source("065accord-update-cch.R") # This file

rm(list= ls())
source("060accord_olink_analytical_dataset040323.R") # Script that generates dataframes
require(survival)


# Subcohort only
#--alb_subcohort <- alb %>% filter(SUBCO15 == 1) %>% select(-SUBCO15)

#---- Input Info modified (if needed)  ---------
df_Info     <- df_initInfo

df_Info$cfilter <- "FEMALE == 1"
df_Info$cfilter_comment <- "Females only"
df_Info$time_horizon <- 10  # 10 years, if vector with two elements use second element to define tm_cut (Inf no truncation)
df_Info$dfin1_name[2] <- "accord_cch" # original and new name

# print(df_Info)

# `dfCCH_Info` 
dfCCH_Info <- dfCCH_initInfo


source("./src/add_aux_vars.R")

keep_objects <- c("accord_cch", "df_Info", "dfCCH_Info","tvars_mtx"  )

# Cleanup (No changes below) 
ls_objects <- ls()
rm_objects  <- c(setdiff(ls_objects, keep_objects), "ls_objects")
#rm(list = rm_objects)
rm(rm_objects)
