#======  Update `dfin_name` data frame with auxilary variables
source("./R/zzz_Rfuns.R") # R functions loaded


# Unpack `df_Info` list

#---- Step 0: Check input info

# Make sure no new components created in `df_Info` list
 txt1 <-  list_added_components (df_initInfo, df_Info)
 message(paste0("--- # df_initInfo vs  df_Info. ", txt1))

 
# Unpack df_Info
nms0 <-  names(df_Info)
for (nm in nms0) assign(nm, df_Info[[nm]], envir = .GlobalEnv)

if (is.null(df_Info$CCH_data)) {
     df_Info$CCH_data <- FALSE
     CCH_data <- FALSE
  }
  
if (CCH_data){
  # unpack dfCCH_Info
  # Make sure no new components created in `df_Info` list
  nms0 <- names(dfCCH_initInfo)
  nms1 <- names(dfCCH_Info)
  added_dfCCH_Info_components <- setdiff(nms1, nms0)
  for (nm in nms0) assign(nm, dfCCH_Info[[nm]], envir = .GlobalEnv)
  tvars <- dfCCH_Info$CCH_tvars
} # if (CCH_data)
 
 ## for (nm in nms0) assign(nm, df_Info[[nm]], envir = .GlobalEnv)


tm_cut <- if (length(time_horizon) ==2) time_horizon[2] else time_horizon[1]

DF_name <- dfin_name  # One or two dfin names
rm(dfin_name)

 df_no   <- 1
 dfin_name <- DF_name[1]
 message("=====> # data frame `", dfin_name, "` modified -----")
 source("./src/add_aux_vars_main.R")


if (length(DF_name) ==2){
  df_no <-2
  dfin_name <- DF_name[2]
  message("=====>#  data frame `", dfin_name, "` mofified -----")

 source("./src/add_aux_vars_main.R")
}


