#======  Update `dfin_name` data frame

# Unpack `df_Info` list

#---- Step 0: Check input info
source("./R/zzz_Rfuns.R") # R functions loaded

# Make sure no new components created in `df_Info` list
nms0 <- names(dfAll_Info)
nms1 <- names(df_Info)
added_df_Info_components <- setdiff(nms1, nms0)

if (length(added_df_Info_components) == 0){
        message ("--- No new components created in `df_Info` : ... OK")
    } else {
        message("--- # Number of added `df Info` components is ", 
        length(added_df_Info_components),
        ". Error: It should be zero")
    } 
    
# Unpack df_Info

for (nm in nms0) assign(nm, df_Info[[nm]], envir = .GlobalEnv)

tm_cut <- if (length(time_horizon) ==2) time_horizon[2] else time_horizon[1]

DF_name <- dfin_name  # One or two dfin names
rm(dfin_name)

 df_no   <- 1
 dfin_name <- DF_name[1]
 message("=====> # data frame `", dfin_name, "` updated -----")
 source("./src/add_aux_vars_main.R")


if (length(DF_name) ==2){
  df_no <-2
  dfin_name <- DF_name[2]
  message("=====>#  data frame `", dfin_name, "` updated -----")

 source("./src/add_aux_vars_main.R")
}


