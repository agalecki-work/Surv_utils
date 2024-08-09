## source("060accord_olink_analytical_dataset040323.R")  # This file

rm(list =ls())
library(dplyr)

# STEP 1: Create data frames (and auxiliary objects)
current_folder <-  getwd()
datain_basename <- "accord_olink_analytical_dataset040323" # Without extension
datain_extension <- "Rdata"

load(paste0(current_folder, "/data/", datain_basename, ".", datain_extension), verbose =TRUE)

accord <- olink_analytical_dataset040323 %>% filter(YRS_PRIMARY > 0)


#--- Derive variables

#`strtm` variable created

accord <- accord %>%
  mutate(strtm = case_when(
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
# Split by alb status ( skipped)
# -- normo <- filter(accord, UACR_gp1 == 1) #n=961
# -- alb   <- filter(accord, UACR_gp1 == 2) #n=432
##############################################################################################

#----  Prepare info (all variables to be included in data)

# Prepare `keep_cvars` vector (include weight and filter vars, if any)
nx <-21
BM_cvars  <- paste("BM",1:nx, sep="")
BMQ_cvars <- paste("BMQ",1:nx, sep="")
CCN_cvars <- paste("CCN", 1:7, sep="")
cvars0 <- c("BPTRIAL", "GLYINT", "BPINT", "strtm", "SUBCO15")
cvars1 <- c("BASE_UACR", "BASE_GFR", "HBA1C") 
cvars2    <- c("FEMALE","AGE")
keep_cxvars <- c(BM_cvars, cvars0, cvars1, cvars2) # Variables to keep (DO NOT include time variables, `subcohort`, `cch_case` variables) 

#--- `tvars?` lists 
tvar1 <- list(
    tvars  = c("YRS_PRIMARY", "PRIMARY"),  #  Pair of variables used to create Surv objects for Cox model
    tlabels = c("Time to primary outcome or censoring (years)", "Primary outcome (ESKD/Dialysis, 0=NO, 1=YES)"),
    svalues = 0:1,                         # event status variable values
    slevels = c("censored", "ESKD/Dialysis"))

tvar2 <- list(
    tvars  = c("YRS_CASE40_JUN", "CASE40_JUNE"),  #  Pair of variables used to create Surv objects for Cox model
    tlabels = c("Time to secondary outcome (yrs)", "Secondary outcome (ESKD/Dialysis/eGFR)"),
    svalues = 0:1,                         # event status variable values
    slevels = c("censored", "ESKD/Dialysis/eGFR"))
    
tvar3 <- list(
    tvars  = c("YRS_DECLINE40_PLUS", "DECLINE40_PLUS"),  #  Pair of variables used to create Surv objects for Cox model
    tlabels = c("Time to 40pct eGFR decline event or cens. (yrs)", "40pct eGFR decline"),
    svalues = 0:1,                         # event status variable values
    slevels = c("censored", "40pct eGFR decline"))
    
tvar4 <- list(
    tvars  = c("FU_TM_ACCORDION", "TM_ACCORDION"),  #  Pair of variables used to create Surv objects for Cox model
    tlabels = c("Time to death from any cause (years)", "Death from any cause"),
    svalues = 0:1,                         # event status variable values
    slevels = c("censored", "Death from any cause"))

tvar5 <- list(
    tvars  = c("YRS_PRIMARY", "STATUS_PRI"),  #  Pair of variables used to create Surv objects for competing risk model
    tlabels = c("Time to primary outcome (ESKD/Dialysis (years)", "Status for primary outcome"),
    svalues = 0:2,                         # event status variable values
    slevels = c("censored", "Primary event", "Death before primary outcome"))

tvar6 <- list(
    tvars  = c("YRS_CASE40_JUN", "STATUS_SEC"),  #  Pair of variables used to create Surv objects for competing risk model
    tlabels = c("Time to secondary outcome (yrs)", "Status for secondary outcome"),
    svalues = 0:2,                         # event status variable values
    slevels = c("censored", "Primary event", "Death before primary outcome"))
   

#   Select one tvars list !!!
tvar_select <- tvar5 # 


# Fine-Gray name (ignored if `tvar_select` has one row, i.e. no competing risk)

FG_dfname <- paste0("accord_FG.", tvar_select$tvars[1])

# Mandatory list `df_initInfo`
df_initInfo <- list(
   current_folder   = current_folder,
   datain_script    = "060accord_olink_analytical_dataset040323",  # R script (his file) that creates data frames 
   datain_basename  = datain_basename,                             # External file with dataset (without extension)
   datain_extension = datain_extension,                            
   dfnms_all        = "accord",                                    # Data frames created by this script
   dfin_name        = c("accord","accord_updated"),                # Data frame names (original, updated)
   keep_xvars       = keep_cxvars,
   CR_tvar          = length(tvar_select$svalues) ==3,             # TRUE/FALSE indicates whether competing risks
   CCH_data         = TRUE,                                        # Creates CCH data(`df_CCH_info` list is needed
   id               = "MASKID",
   tvar_select      = tvar_select,                                 # Select `tvars` vector
   FG_dfname        = FG_dfname,
   cfilter          = character(0), # Filter expression 
   cfilter_comment  = "All data used",
   time_horizon     = Inf,         # Inf -> no time truncation , Second element (if present) will be used as `tm_cut`
   seed             = numeric(0),  # seed
   initSplit        = 0.8,         # numeric(0) -> No split, 0.8 implies 80/20 split
   nfolds           = 10
)

## df_CCH_info ( \2023_Joslin_AD_HS\_admin\2023-02-atg-notes\project_update4_2AD.pptx)
# colnames(accord)  # Data dictionary Jan112022.xlsx
#  outside_SUBCO <- accord %>% filter(SUBCO15 ==0)
#  inside_SUBCO <- accord %>% filter(SUBCO15 ==1)
# with(inside_SUBCO, table(PRIMARY, TM_ACCORDION, useNA = "always"))
#>       TM_ACCORDION
#> PRIMARY   0   1 <NA>
#>   0    914 195    0   1109 non-cases(including 195 deaths) inside subcohort
#>   1     35   6    0   41 cases

# with(outside_SUBCO, table(PRIMARY, TM_ACCORDION, useNA = "always"))
#>        TM_ACCORDION
#> PRIMARY   0   1 <NA>
#>   0    528 116    0 Depending on CCH_tvars exclude n=528 or 528 + 151 subjects
#>   1    151  64    0 n=215 cases outside of subcohort

# CCH_case <- if(length(tvar_select$svalues) ==2) tvar_select$tvar[2] else paste0(tvar_select$tvar[2], "_CCHcase") 

# Mandatory list for CCH data (CCH_data is TRUE)
dfCCH_initInfo <- list(
   subcohort    = "SUBCO15",      # Subcohort variable name (string) for data from CCH studies
   cch_case     = "CCH_ucase"     # Name of <case variable> (string) to be created. Depends on status variable
)

## accord[, CCH_case] <- eval(as.name(CCH_case)) # cch_case variable created

keep_objects <- c("accord", "df_initInfo", "dfCCH_initInfo") # Objects mandatory to keep `df_initInfo`, `dfCCH_initInfo`

# print(df_initInfo)
# print(dfCCH_initInfo)

# Cleanup (No changes below) 
ls_objects <- ls()
rm_objects  <- c(setdiff(ls_objects, keep_objects), "ls_objects")
rm(list = rm_objects)
rm(rm_objects)
