
#source("022accord-update-cch.R") # This file

rm(list= ls())
source("020accord_Bala0724.R") # Script that generates dataframes
require(survival)


# Subcohort only
#--alb_subcohort <- alb %>% filter(SUBCO15 == 1) %>% select(-SUBCO15)

#---- Input Info modified (if needed)  ---------
df_Info     <- df_initInfo

df_Info$cfilter <- "UACR_gp1 == 2"
df_Info$cfilter_comment <- "Albuminuria only"
df_Info$time_horizon <- 10  # 10 years, if vector with two elements use second element to define tm_cut (Inf no truncation)
df_Info$CCH_data    <- FALSE

# print(df_Info)

# `dfCCH_Info` Not needed in the context of 
source("./src/add_aux_vars.R")

