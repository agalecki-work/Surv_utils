# source("065accord-mod.R") # This file

rm(list= ls())

#--- Create mandatory `df_initInfo` list and `work_data' dataframe
source("061accord-update-subcohort.R") 
#print(data_initInfo)
source("./R/zzz_Rfuns.R")    # R functions loaded
message("====> 065*.R  STARTS")

require(glmnet)
require(splines)


# Auxiliary objects created for later use

train_data <- work_data %>% filter(initSplit == 1)
message("======> `train_data` : ", nrow(train_data), "x" , ncol(train_data))

val_data <- work_data %>% filter(initSplit == 0)
message("======> `val_data` : ", nrow(val_data), "x" ,ncol(val_data))


BM_vars <- paste("BM", 1:21, sep = "")
xvars    <- c("AGE")
nsdf3_vars <- c(BM_vars, xvars) # Splines withh df=3 will be generated for these variables

ns_df3 <- sapply(nsdf3_vars, FUN= function(cx){
  splinex <- ns(train_data[, cx],df=3) 
  attr(splinex, "knots")
})  # matrix with spline knots for selected vars,  df=3. Colnames correspond to var names

message("====> 065*.R  STARTS")


cxterms_pattern1 <- paste("BM", 1:21, sep = "")
#                           ns(BM1         , knots = ns_df3[,'BM1'])
cxterms_pattern2 <- paste( "ns(BM", 1:21, ", knots = ns_df3[,'BM", 1:21, "'])", sep ="" )
cxterms_pattern <- cbind(cxterms_pattern1, cxterms_pattern2) 

cxterms_common  <- c("AGE") # , "ns(AGE         , knots = ns_df3[,'AGE'])", "BASE_UACR")
cxterms_mtx <- create_cxterms_mtx(cxterms_pattern1, cxterms_common) 
print(head(cxterms_mtx))


message("====> Mod_Info ")
mod_Info <- list(
  mtx_spec       = FALSE,      # use `cxterms_mtx` or `cx_terms` model spec
  wght           = "CCH_Self",       # ... CCH_Self,  CCH_SelfPrentice, CCH_BorganI
  id             = "MASKID",
  cxterms_mtx    = cxterms_mtx,
  cxterms_mtx_tt = c(2), # select columns in `cxterms_mtx`. Possibly NULL

  cxterms    = c("AGE", "log(AGE)", 
                 "ns(BM1, knots = ns_df3[,'BM1'])",
                 "ns(BM5, knots = ns_df3[,'BM5'])"
                 ), # cxterms
  cxterms_tt = numeric(0), # c(2),  Select element(s) from `cxterms_` vector defined above, numeric(0) to skip tt()
  tt_split_length  = 0.1          # 0.1, 0.01 Length of tt_split_interval used to create expanded data
)
rm(cxterms_mtx, cxterms_pattern, cxterms_common) 

# Determine ncols in  X_mtx
cxterms_plus   <- paste(mod_Info$cxterms, collapse ="+" ) # 'x1+x2'
cxform         <- paste("~ 0 +", cxterms_plus)       # '~0 +x1+x2'
Xmtx           <- model.matrix(as.formula(cxform), data = train_data) 
ncolX          <- length(colnames(Xmtx))
print(ncolX)

glmnet_Info <- list(
    alpha=0.5, 
    penalty.factor = rep(1, times =ncolX)
)

#==== source
source("./src/fit_model0.R") 

if (mod_mtx_spec){
#Select one fit
cox0_fit  <- cox0_xfits[[1]]
zph_test <- cox.zph(cox0_fit)

cox0_zphs <- lapply(cox0_xfits, FUN= function(fitx) cox.zph(fitx))
names(cox0_zphs) <-  cpatt_nms
print(cox0_zphs)
}
source("./src/fit_model_tt.R") 


keep0_objects <- if (ntvarsx  == 2) {
   descript <- paste0("Cox for time to event: ",  tv_tnms[1], ',', tv_tnms[2])
   c("train_data", "val_data")
  } else {
   descript <- paste0("Competing risks for: ", tv_tnms[1], ',', tv_tnms[2])
   c("train_fgdata", "val_fgdata")
  }
  
keep0_objects <- if (mod_mtx_spec){
    descript <- paste0(descript,  ". ", length(cox0_FITs), " models stored in `cox0_FITs` fitted using coxph()")  
    c(keep0_objects, "cox0_args", "cox0_FITs")
   } else {
    descript <- paste0(descript,  ". Model fitted  using glmnet stored in `coxnet0_fit`") 
    c(keep0_objects, "coxnet0_args" , "coxnet0_fit")
   } 
#print(keep0_objects)
   
keep_objects <- c(keep0_objects , "descript",  "data_Info", "work_data", "mod_info", "glmnet_Info")

# print(df_initInfo)

# Cleanup (No changes below) 
ls_objects <- ls()
rm_objects  <- c(setdiff(ls_objects, keep_objects), "ls_objects")
rm(list = rm_objects)
rm(rm_objects)



