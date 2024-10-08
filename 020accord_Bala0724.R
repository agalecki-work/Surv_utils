## source("020accord_Bala0724.R")

rm(list =ls())

library (openxlsx)
library(dplyr)

# STEP 1: Create data frames
current_folder <-  getwd()
datain_basename <- "accord_Bala0724" # Without extension
datain_extension <- "xlsx"

accord  <-read.xlsx(paste0(current_folder, "/data/", datain_basename, ".", datain_extension))

accord <- accord %>%
  mutate(stratm = case_when(
    BPTRIAL == 0 & GLYINT == 0 & FIBRATE == 0 ~ 1,
    BPTRIAL == 0 & GLYINT == 0 & FIBRATE == 1 ~ 2,
    BPTRIAL == 0 & GLYINT == 1 & FIBRATE == 0 ~ 3,
    BPTRIAL == 0 & GLYINT == 1 & FIBRATE == 1 ~ 4,
    BPTRIAL == 1 & GLYINT == 0 & BPINT == 0 ~ 5,
    BPTRIAL == 1 & GLYINT == 0 & BPINT == 1 ~ 6,
    BPTRIAL == 1 & GLYINT == 1 & BPINT == 0 ~ 7,
    BPTRIAL == 1 & GLYINT == 1 & BPINT == 1 ~ 8,
    TRUE ~ NA_integer_  # This handles any other cases that do not match the above conditions
  ))
  
##############################################################################################
# Split by alb status
# -- normo <- filter(accord, UACR_gp1 == 1) #n=961
# -- alb   <- filter(accord, UACR_gp1 == 2) #n=432
##############################################################################################


tvars1 <- c("YRS_PRIMAR", "PRIMARY")             #  Variables' names used to create Surv objects
tvars2 <- c("YRS_CASE40", "CASE40_JUN")
tvars3 <- c("YRS_DECLIN", "DECLINE40_")
tvars4 <- c("YRS_CASE50", "case50_jun")          # Competing risk (if any) included in the last row of `tvars_all` matrix

tvars_all <- rbind(tvars1, tvars2, tvars3, tvars4)
colnames(tvars_all) <- c("timevar", "eventvar")
rownames(tvars_all) <- tvars_all[ , 1]
tvars_all 


# Mandatory list `dfAll_info`
dfAll_Info <- list(
   current_folder = current_folder,
   datain_script  = "002accord_Bala0724",  # R script that creates data frames 
   datain_basename = datain_basename,
   datain_extension = datain_extension, 
   dfnms_all   = c("accord"),  # Data frames created by this script
   dfin_name   = "accord", # One or two data frames (training and/or validation) selected
   CCH_data    = TRUE,
   id          = "MaskID",
   tvars_all   = tvars_all,    # Matrix with  variables' names used to create Surv objects
   cfilter     = "UACR_gp1 == 2",     # alb dataset
   cfilter_comment = "Albuminuria",
   time_horizon = Inf, 
   initSplit    = 0.8,
   nfolds       = 10
)

## df_CCH_info

tnms_all <- rownames(tvars_all)
ti_select   <- c(2,3)             # Select one or two tnames (second tname, if present treated as competing risk)  
CCH_tvars <- tvars_all[ti_select,]
CCH_tvars

cch_case <-  tvars_all[1,2]      # Case variable by default status variable for the first outcome (first row in tvars matrix)

df_CCH_info <- list(
   CCH_tvars    = CCH_tvars       # One or two rows from tvars matrix
   subcohort    = "SUBCO15",      # Variable name (string) for data from C-CH studies
   cch_case     = cch_case,
   total_cohort_size = 8000

)
rm(tvars1, tvars2, tvars3, tvars4)           # Cleanup

rm(current_folder, datain_basename, datain_extension, tvars_all)
# print(dfAll_Info)
