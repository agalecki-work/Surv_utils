#======  Update `dfin_name` data frame with auxilary variables
source("./R/zzz_Rfuns.R")    # R functions loaded
if (is.null(df_Info$CCH_data)) df_Info$CCH_data <- FALSE

keep_Allvars <- df_Info$id 

#---- Step 0: Check input info

# Make sure no new components created in `df_Info` list compared to `df_initInfo`
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
 


tm_cut <- if (length(time_horizon) == 2) time_horizon[2] else time_horizon[1]

common_vars <- intersect(keep_vars, colnames(eval(as.name(dfin1_name))))

if (length(dfin2_name) !=0) common_vars <- intersect(common_vars, colnames(eval(as.name(dfin2_name)))) 

## Process dfin1_name[1] original df

 df_no   <- 1
 dfin_name <- dfin1_name[1]
 dfnew_name <-  if (length(dfin1_name) == 2)  dfin1_name[2] else character(0)
# message("=====> # data frame `", dfin_name, "`-> `", dfnew_name,  "` modified -----")
 source("./src/add_aux_vars_main.R")


if (length(dfin2_name) !=0){
  df_no <-2
  dfin_name <- dfin2_name[1]
  dfnew_name <- if (length(dfin2_name) == 2) dfin2_name[2] else character(0)

  #message("=====>#  data frame `", dfin2_name, "` ->",  processed -----")

 source("./src/add_aux_vars_main.R")
}


