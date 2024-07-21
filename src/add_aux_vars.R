#======  Update `df_name` data frame

# Unpack `df_Info` list

#---- Step 0: Check input info
source("./R/zzz_Rfuns.R") # R functions loaded

# Make sure no new components created in `df_Info` list
nms0 <- names(dfAll_Info)
nms1 <- names(df_Info)
print(setdiff(nms1, nms0))  # character(0)

# Unpack df_Info

for (nm in nms0) assign(nm, df_Info[[nm]], envir = .GlobalEnv)

DF_name <- df_name
rm(df_name)

message("==1")

 df_name <- DF_name[1]
 source("./src/add_aux_vars_main.R")
message("==2")


if (length(DF_name) ==2){
 df_name <- DF_name[2]
 source("./src/add_aux_vars_main.R")
}


