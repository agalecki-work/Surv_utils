## source("010cric_olinknpx_112023_v1_imputed0.R")

rm(list =ls())


require(dplyr)

# STEP 1: Create data frames
current_folder <-  getwd()
datain_basename <- "cric_olinknpx_112023_v1_imputed0" # Without extension
datain_extension <- "Rdata"

load(paste0(current_folder, "/data/", datain_basename, ".", datain_extension), verbose=TRUE)

cric_imputed <- dtx_imputed0
message("==>===> `cric_imputed` data: ", nrow(cric_imputed), " x ", ncol(cric_imputed)) 

path_Info <- list(
   cdir             = current_folder,
   script_name      = "cric_olinknpx_112023_v1_imputed0",  # R script (this file) 
   dfin_base        = datain_basename,                             # External file with dataset (without extension)
   dfin_ext         = datain_extension,                            
   dfnms_all        = "cric_imputed",                                    # Data frame names created by this script
   out_prefix       = "NOT USED"                            # used in 061* script
)

#---- Derive variables ( if any)

#----  Prepare info 

#--- `tvar?` lists (one list will be selected)


tvar1 <- list(
    tnms     = c("TIME_ESRD", "ESRD"),  #  Variables' names used to create Surv objects
    tlabels  =  c("Time to primary outcome or censoring (years)", "Primary outcome (ESKD/Dialysis, 0=NO, 1=YES)"),
    slevels = 0:1,                         # event status variable values
    slabels = c("0-censored", "1-ESKD/Dialysis"))

tvars2 <- c("TIME_LOSS50", "LOSS50")
tvars3 <- c("TIME_LOSS50_ESRD", "LOSS50_ESRD")
tvars4 <- c("TIME_DEATH", "DEAD")          # Competing risk (if any) included in the last row of `tvars_all` matrix

   
#   Select one tvar list !!!
tvar_Info <- tvar1 # 


# Mandatory (template) list `dfAll_info`
dfin_Info <- list(
   name       = "cric_imputed",     # Note: Two data frames, if external validation 
   varsin     = dfvars_in,
   cfilter    = character(0),  # string with filter stmnt 
   cfilter_comment  = "All data used",
   time_horizon    = c(10,9.99),    # Second element used as a cut-off 
)
rm(current_folder, datain_basename, datain_extension, tvars_all)
message("--- print(dfin_Info)")
# print(dfin_Info)

#-- split_Info

split_Info <- list(
   seed             = numeric(0),  # seed
   initSplit        = 0.8,         # "X" for external,  0.8 implies 80/20 split
   nfolds           = 10
)

# Mandatory list `Data_initInfo`
data_initInfo <- list(
   path_Info        = path_Info,              # name, varsin, cfilter, cfilter_comment, time_horizon 
   tvar_Info        = tvar_Info,              # tnms, tlabels, slevels, slabels
   dfin_Info        = dfin_Info,
   CCH_Info         = CCH_Info,               # subcohort, weight, n_total
   split_Info       = split_Info              # seed, initSplit, nfolds
 
)

