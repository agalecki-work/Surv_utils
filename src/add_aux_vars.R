#======  Update `dfin_name` data frame with auxilary variables
source("./R/zzz_Rfuns.R")    # R functions loaded

#--- update default values

# NULL -> charcter(0) or numeric(0)
if (is.null(df_Info$CCH_data))  df_Info$CCH_data <- FALSE
if (is.null(df_Info$keep_vars)) df_Info$keep_vars <- character(0)
if (is.null(df_Info$cfilter)) df_Info$cfilter <- character(0)
if (is.null(df_Info$seed)) df_Info$seed <- numeric(0)
if (is.null(df_Info$initSplit)) df_Info$initSplit <- numeric(0)


# Populate first component
if (length(df_Info$keep_vars)== 0) df_Info$keep_vars <- colnames(eval(as.name(df_Info$dfin1_name)))

keep_Allvars <- df_Info$id  


# Populate second component (if empty)

if (length(df_Info$CCH_data) == 1) df_Info$CCH_data <- c(df_Info$CCH_data, FALSE)
if (length(df_Info$cfilter) == 1) df_Info$cfilter <- c(df_Info$cfilter, df_Info$cfilter)
if (length(df_Info$time_horizon) == 1) df_Info$time_horizon <- c(df_Info$time_horizon, df_Info$time_horizon)

if (length(df_Info$initSplit) == 1) df_Info$initSplit  <- c(df_Info$initSplit , numeric(0))
if (length(df_Info$nfolds) == 1) df_Info$nfolds  <- c(df_Info$nfolds , numeric(0))


# Unpack `df_Info` list


#---- Step 0: Check input info

# Make sure no new components created in `df_Info` list
 txt1 <-  list_added_components (df_initInfo, df_Info)
 message(paste0("--- # df_initInfo vs  df_Info. ", txt1, "     ... error?"))

 
# Unpack df_Info
nms0 <-  names(df_Info)
for (nm in nms0) assign(nm, df_Info[[nm]], envir = .GlobalEnv)

  
if (CCH_data){
  # unpack dfCCH_Info
  # Make sure no new components created in `dfCCH_Info` list
  nms0 <- names(dfCCH_initInfo)
  nms1 <- names(dfCCH_Info)
  added_dfCCH_Info_components <- setdiff(nms1, nms0)
  for (nm in nms0) assign(nm, dfCCH_Info[[nm]], envir = .GlobalEnv)
  tvars <- dfCCH_Info$CCH_tvars
} # if (CCH_data)
 


tm_cut <- time_horizon[2]


## Process dfin1_nm

 df_no   <- 1
 dfin_name <- dfin1_nm
 message("=====> # data frame `", dfin1_nm, "` modified -----")
 source("./src/add_aux_vars_main.R")


if (length(dfin2_nm) !=0){
  df_no <-2
  dfin_name <- dfin2_nm
  message("=====>#  data frame `", dfin2_nm, "` processed -----")

 source("./src/add_aux_vars_main.R")
}


