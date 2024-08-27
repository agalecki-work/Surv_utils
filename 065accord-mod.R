# source("065accord-mod.R") # This file

rm(list= ls())

#--- Create mandatory `df_initInfo` list and `work_data' dataframe
source("061accord-update-subcohort.R") 
#print(data_initInfo)
source("./R/zzz_Rfuns.R")    # R functions loaded
message("====> 065*.R  STARTS")


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
  wght           = character(0),                       # weight variable (if any)
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

#==== source


#---- Unpack df_Info and 
#  path_Info, tvar_Info dfin_Info CCH_Info split_Info mod_Info 
dtInfo <- data_Info

dtInfo_nms <-  names(dtInfo)
for (nm in dtInfo_nms) assign(nm, dtInfo[[nm]], envir = .GlobalEnv)
# print(dtInfo_nms)

#---- extract auxiliary objects

#--tvar_info
tv_tnms    <- tvar_Info$tnms      # Time and status variables
tv_slevels <- tvar_Info$slevels
tv_slabels <- tvar_Info$slabels
message("-- tvar selected: ", tv_tnms[1], ", status var: ", tv_tnms[2])
ntvarsx  <- length(tv_slevels) # 2 or 3

#--mod_Info
mod_mtx_spec <- mod_Info$mtx_spec
mod_id   <- mod_Info$id
mod_wght <- mod_Info$wght
mod_cxterms_mtx<- mod_Info$cxterms_mtx        # Matrix spec, multiple models
mod_cxterms_mtx_tt<- mod_Info$cxterms_mtx_tt  # select columns in `cxterms_mtx`. Possibly NULL
mod_cxterms       <- unique(mod_Info$cxterms) # Vector spec, one model 
mod_cxterms_tt    <- mod_Info$cxterms_tt      # Select element(s) 

# Vector with tt cxterms 
cxterms_tt <- if (mod_mtx_spec) unique(mod_cxterms_mtx[, mod_cxterms_mtx_tt]) else mod_cxterms[mod_cxterms_tt]
  
if (mod_mtx_spec){  # Create `cpatt_nms`
  matches <- grep("^cpatt",  colnames(mod_cxterms_mtx), value = TRUE)
  tmp_mtx <- mod_cxterms_mtx[ , matches ]
  cpatt_nms <-  if (is.null(dim(tmp_mtx))) tmp_mtx else apply(tmp_mtx, 1, paste, collapse=":") 
} 


#mod_cxterms_tt <- mod_Info$cxterms_tt         # indices to select
#cxterms_ttselx <- mod_cxterms[mod_cxterms_tt] # Select main effects to include with time interactions
# cxterms_ttx    <- if(length(cxterms_ttselx)) paste(cxterms_ttselx, ":", tv_tnms[1], sep="") else character(0) # interactios with futime 

#====== Create `train_fgdata` and `val_fgdata` using finegray function
if (ntvarsx  >= 3){ # finegray()
  message("====> Expanded data for competing risks for: ", tv_tnms[1], " finegray() created" )
  message("--- `train_data` ", nrow(train_data), "x", ncol(train_data)) 
  # Expand Data Using finegray for event type 1
  train_fgdata <- expand_data_finegray(train_data, tvar_Info = tvar_Info, cwght = mod_wght, cid = mod_id) #
  message("--- `train_fgdata` ", nrow(train_fgdata), "x", ncol(train_fgdata)) 

  if (!is.null(val_data)){
    message("---  `val_data` ", nrow(val_data), "x", ncol(val_data)) 
    val_fgdata <- expand_data_finegray(val_data, tvar_Info = tvar_Info, cwght = mod_wght, cid = mod_id ) #
     message("--- `val_fgdata` ", nrow(val_fgdata), "x", ncol(val_fgdata)) 

  } # !is.null(val_data))
} else { # if ntvarsx >= 3
  message ("====> Datasets `train_fgdata` and ` val_fgdata _NOT_ created ... OK")
}


#==== Run coxph models _without_ tt() interaction terms for each row of `cterms_mtx` matrix
message("===> Step Model _without_ tt() interaction terms:", ntvarsx, ", mtx_spec=", mod_mtx_spec )

if (ntvarsx  == 2 && mod_mtx_spec){ # multiple coxph using `train_data`  wout tt vars
 cox0_FITs <- lapply(1:nrow(mod_cxterms_mtx), FUN = function(i) {
    cxterms        <- mod_cxterms_mtx[i,] # `cxterms` for  model wout tt vars
    cxterms_plus   <- paste(cxterms, collapse ="+" )
    cxform_srv     <- paste0("Surv(", tv_tnms[1], ',', tv_tnms[2],") ~ 0 +", cxterms_plus)
    args_list <- list(data = train_data, 
                      formula = as.formula(cxform_srv)               
                      )
    if (length(mod_wght)> 0) args_list$weights =  train_data[[mod_wght]]
    if (length(mod_id)> 0)   args_list$id =  train_data[[mod_id]]
     
    cox0_fit <-  do.call(coxph, args_list) 
    return(cox0_fit) 
 })
  names(cox0_FITs) <- cpatt_nms
  cox0_xfits <- cox0_FITs  

 } # if ntvarsx  == 2 and mod_mtx_spec = TRUE
 
if (ntvarsx  >= 3 &&  mod_mtx_spec) {            # coxph using `train_fgdata` wout ttvars
  cox0_fgFITs <- lapply(1:nrow(mod_cxterms_mtx), FUN = function(i) {
      cxterms        <- mod_cxterms_mtx[i,]
      cxterms_plus   <- paste(cxterms, collapse ="+" )
      cxform_fgsrv   <- paste0("Surv(fgstart, fgstop, fgstatus) ~ 0 +", cxterms_plus)
      args_list <- list(data = train_fgdata, 
                        formula = as.formula(cxform_fgsrv)               
                        )
      if (length(mod_wght)> 0) args_list$weights =  train_fgdata[[mod_wght]]
      if (length(mod_id)> 0)   args_list$id =  train_fgdata[[mod_id]]
       cox0_fit <-  do.call(coxph, args_list) 
       return(cox0_fit) 
	 })
    names(cox0_fgFITs) <- cpatt_nms
    cox0_xfits <- cox0_fgFITs  
 } # if ntvarsx  >= 3 and mod_mtx_spec = FALSE


if (ntvarsx  >= 3 && !mod_mtx_spec) {            # glmnet using `train_fgdata` wout ttvars
      cxterms        <- mod_cxterms_mtx
      cxterms_plus   <- paste(cxterms, collapse ="+" )
      cxform_fgsrv   <- paste0("Surv(fgstart, fgstop, fgstatus) ~ 0 +", cxterms_plus)
      X_train        <- model.matrix(as.formula(cxform_fgsrv), data = train_fgdata)
      Y_train        <- with(train_fgdata, Surv(fgstart, fgstop, fgstatus))
      args_list <- list(x = X_train,
                        y = Y_train,          
                        family = "cox"
                        )
      if (length(mod_wght)> 0) args_list$weights =  train_fgdata[[mod_wght]]
      if (length(mod_id)> 0)   args_list$id =  train_fgdata[[mod_id]]
      coxnet0_fit <-  do.call(glmnet, args_list) 
  } # if ntvarsx  >= 3 and mod_mtx_spec = TRUE


if (mod_mtx_spec){
#Select one fit
cox0_fit  <- cox0_xfits[[1]]
zph_test <- cox.zph(cox0_fit)

cox0_zphs <- lapply(cox0_xfits, FUN= function(fitx) cox.zph(fitx))
names(cox0_zphs) <-  cpatt_nms
print(cox0_zphs)
}

#=====> Time transformation
message("===Time transformatiom for:")
print(cxterms_tt)

if (ntvarsx  >= 3 & length(mod_cxterms_tt) > 0){ # Split time in data created by finegray()
   message(" ----> FG  Data with split time to accommodate time-dependent coefficients")
   tmp_tt   <- mod_cxterms_[mod_cxterms_tt]

# Define the cut points for time intervals
cut_points <- seq(0, max(train_fgdata$fgstop), by =  tt_split_length)  # Define 'some_interval' appropriately

# Split the data
 train_split_fgdata <- survSplit(Surv(fgstart, fgstop, fgstatus) ~ ., 
                        data = train_fgdata,                     
                        cut = cut_points,
                        episode = "interval")
 # Adjust the time-varying covariate
 # split_data$SEX_time <- (split_data$SEX-1)*sqrt(split_data$fgstop)
 
 
 if (!is.null(val_data)){
  val_split_fgdata <- survSplit(Surv(fgstart, fgstop, fgstatus) ~ ., 
                        data = val_fgdata,                     
                        cut = cut_points,
                        episode = "interval")
  }   # if !is.null(val_data)
 
# Adjust the time-varying covariate
 # split_data$SEX_time <- (split_data$SEX-1)*sqrt(split_data$fgstop)

} #  if ntvarsx  >= 3, finegray()


# fgfit1tm1_split <- coxph(Surv(fgstart, fgstop, fgstatus) ~ SEX + SEX_time, 
#          data=split_data, weight= fgwt, id =PID)
# print(summary(fgfit1tm1_split))




if (length(mod_cxterms_tt) > 0){  # time transformation variables
   message(" ----> Data expansion to accommodate time-dependent coefficients")
   tmp_tt   <- mod_cxterms_[mod_cxterms_tt]
   cxterms0 <- paste( tmp_tt, ":", "YRS_PRIMARY", sep="")
   #cxterms <-  c(mod_cxterms0, mod_cxterms_, cxterms0) 
  } else { # No tt transformation
   ## cxterms <- c( mod_cxterms0, mod_cxterms_)
  }
 
# print(cxterms)

ff <- function(x){ 
 fcxterms <- paste(cxterms,  collapse ="+")
 print(fcxterms)
 
 formcx  <- paste0("~0 +", fcxterms)
 csurv_form <-  paste0("Surv(YRS_PRIMARY, STATUS_PRI) ~ 0 +", fcxterms)
 
 train_Xmtx <- model.matrix(as.formula(formcx), data= train_data)
 cox_fit1 <- coxph(as.formula(csurv_form), data = train_data)
 summary(cox_fit1)
 cox.zph(cox_fit1)
}





