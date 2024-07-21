# source("011cric-update-srs.R")

rm(list=ls())
require(survival)

source("010cric_olinknpx_112023_v1_imputed0.R") # Data frame `cric_imputed` createed

print(ls()) # Objects created

#---- Input Info   ---------

#---- Input Info updated   ---------
df_Info     <- dfAll_Info
df_Info$df_name <- "cric_imputed"
df_Info$time_horizon <- c(10, 9.99)  # 10 years, Inf no truncation

source("./src/add_aux_vars.R")

