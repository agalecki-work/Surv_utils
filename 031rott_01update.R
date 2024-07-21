
#source("031rott_01update.R") # This file

rm(list= ls())
source("030rott_01data.R") 
require(survival)


#---- Input Info updated   ---------
df_Info     <- dfAll_Info

df_Info$df_name     <-  c("rott5") # ,  # "gbsg5")
df_Info$CCH_data    <- FALSE

print(df_Info)

source("./src/add_aux_vars.R")

