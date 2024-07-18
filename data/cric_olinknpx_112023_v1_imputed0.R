# rm(list = ls())

# data_path <- "./"

# source("cric_olinknpx_112023_v1_imputed0.R") # to test this script

#
#----------------------------------

Rdata_name <- "cric_olinknpx_112023_v1_imputed0"
Rdata_path <- paste0(data_path, Rdata_name, ".Rdata")
load(Rdata_path, verbose=TRUE)

cric_imputed <- dtx_imputed0
rm(dtx_imputed0) # not needed


