## source("060accord_olink_analytical_dataset040323.R")

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

# Prepare `keep_cvars` vector (include weight and filter vars)
nx <-21
BM_cvars  <- paste("BM",1:nx, sep="")
BMQ_cvars <- paste("BMQ",1:nx, sep="")
CCN_cvars <- paste("CCN", 1:7, sep="")
cvars0 <- c("BPTRIAL", "GLYINT", "BPINT", "strtm")
cvars1 <- c("BASE_UACR", "BASE_GFR", "HBA1C") 
cvars2    <- c("FEMALE","AGE")
keep_cvars <- c(BM_cvars, cvars0, cvars1, cvars2) # Variables to keep 

#--- tvars_all matrix with tow columns: `timevar`, `eventvar`
tvars1 <- c("YRS_PRIMARY", "PRIMARY")             #  Pairs of variables used to create Surv objects
tvars2 <- c("YRS_CASE40_JUN", "CASE40_JUNE")
tvars3 <- c("YRS_DECLINE40_PLUS", "DECLINE40_PLUS")
tvars4 <- c("FU_TM_ACCORDION", "TM_ACCORDION")
tvars_all <- rbind(tvars1, tvars2, tvars3, tvars4)

colnames(tvars_all) <- c("timevar", "eventvar")
rownames(tvars_all) <- tvars_all[ , 1]  # Use first column of `tvars` to assign rownames


# Mandatory list `df_initInfo`
df_initInfo <- list(
   current_folder   = current_folder,
   datain_script    = "060accord_olink_analytical_dataset040323",  # R script (his file) that creates data frames 
   datain_basename  = datain_basename,                             # External file with dataset (without extension)
   datain_extension = datain_extension,                            
   dfnms_all        = "accord",                                    # Data frames created by this script
   dfin1_name       = "accord",                                    # Data frame selected
   dfin2_name       = character0(),                                # External data frame
   keep_vars        = keep_cvars,
   CCH_data         = TRUE,                                        # Creates CCH data(`df_CCH_info` list is needed
   id               = "MASKID",
   tvars_all        = tvars_all,    # Matrix with pairs of variables used to create Surv() objects
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


#--- Select (one of two) rows from `tvars_all` matrix for the analysis
#  one row defines Surv() object for the  primary event of interest
#  second row (if present) defines Surv() object for competing risk event

CCHtm_select   <- c("YRS_PRIMARY", "FU_TM_ACCORDION")  # Select one or two tnames from `tvars_all` (second tname, if present treated as competing risk)  
CCH_tvars <- tvars_all[CCHtm_select,]

# Mandatory list for CCH data
dfCCH_initInfo <- list(
   CCH_tvars    = CCH_tvars,      # One or two rows extracted from `tvars_all` matrix
   subcohort    = "SUBCO15",      # Subcohort variable name (string) for data from C-CH studies
   cch_case     = CCH_tvars[1,2], # Case variable by default status variable for the first outcome (first row in tvars matrix)
   total_cohort_size = 7667       # 
)

keep_objects <- c("accord", "df_initInfo", "dfCCH_initInfo") #Mandatory to keep `df_initInfo`, `dfCCH_initInfo`

# Cleanup (No changes below) 
ls_objects <- ls()
rm_objects  <- c(setdiff(ls_objects, keep_objects), "ls_objects")
rm(list = rm_objects)
rm(rm_objects)
