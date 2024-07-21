# source("011cric-update-srs.R")

rm(list=ls())
require(survival)

#------- Template `dfAll_Info` for `df_Info` specific for a given dataset is created 
source("010cric_olinknpx_112023_v1_imputed0.R") # Data frame `cric_imputed` created

ls1 <- ls()

message("--- print(ls1)  # Objects created by data script")
#print(ls1) # Objects created


#---- Input Info updated   ---------
df_Info     <- dfAll_Info
df_Info$time_horizon <- c(10, 9.99)  # 10 years, Inf no truncation
df_Info$cfilter <- "SEX==1"       # Filter (optional)
message("--- print(df_Info)")
## print(df_Info)
source("./src/add_aux_vars.R")

