rm(list=ls())
require(survival)

source("./R/zzz_Rfuns.R") # R functions loaded

data_path <- "./data/"

require(dplyr)

source("./data/cric_olinknpx_112023_v1_imputed0.R") # Data frame `cric_imputed` createed
ls()
rm(data_path, Paths_info, Rdata_path)



#--- Objects available
#  "cric_imputed" "Rdata_name"


#---- Input Info   ---------

df_name <- "cric_imputed"
subcohort <- NULL                            # Variable name (string) for data from C-C studies
tvars1 <- c("TIME_ESRD", "ESRD")             # Variables used to create Surv object
tvars2 <- c("TIME_LOSS50", "LOSS50")
tvars3 <- c("TIME_LOSS50_ESRD", "LOSS50_ESRD")
tvars4 <- c("TIME_DEATH", "DEAD")            # Competing risk included in the last row of `tvars_all` matrix
tvars_all <- rbind(tvars1, tvars2, tvars3, tvars4)
colnames(tvars_all) <- c("timevar", "eventvar")
tvars_all 
rm(tvars1, tvars2, tvars3, tvars4)           # Cleanup


time_horizon <- 10  # 10 years, Inf no truncation
tm_cut       <- 9.99


#---- Step 1: Truncate time for all time variables included in `tvars_all` matrix


# Before truncating time in df
rngs_beforeS1 <-  sapply(tvars_all[,1], FUN =  function(tmx){
         dtx <- eval(as.name(df_name))
         assign("timex", dtx[, tmx])
         range(timex)
 })
rngs_beforeS1

tbls_beforeS1 <-  sapply(tvars_all[,2], FUN =  function(evnt){
         dtx <- eval(as.name(df_name))
         assign("event", dtx[, evnt])
         table(event)
 })
tbls_beforeS1

ntvars <- nrow(tvars_all)
for (i in 1:ntvars){
 assign(df_name, SurvSplit_truncate(eval(as.name(df_name)), tvars_all[i,], tm_cut), envir=.GlobalEnv)
}


# After truncating time

rngs_S1 <-  sapply(tvars_all[,1], FUN =  function(tmx){
         dtx <- eval(as.name(df_name))
         assign("timex", dtx[, tmx])
         range(timex)
 })
rngs_S1

tbls_S1 <-  sapply(tvars_all[,2], FUN =  function(evnt){
         dtx <- eval(as.name(df_name))
         assign("event", dtx[, evnt])
         table(event)
 })
tbls_S1


#--- Step 2: Create competing risk variables (cr_*)

ncrvars <- ntvars-1  # Last row is competing risk

for (i in 1:ncrvars){
 dtx <- eval(as.name(df_name)) # df updated 
 assign(df_name, 
          create_cr_vars(dtx, tvars_all[i,], tvars_all[ncrvars+1 ,] ), 
          envir=.GlobalEnv)
}

cr_vars0 <- tvars_all[ -ntvars,] # Last row omitted

cr_mtx0 <- paste("cr_", cr_vars0, sep="")
cr_mtx <- matrix(cr_mtx0, ncol =2)
colnames(cr_mtx) <- c("cr_time", "cr_event")
nms <- rownames(tvars_all)
rownames(cr_mtx) <- nms[-ntvars]
cr_mtx

cr_rngs_S2 <-  sapply(cr_mtx[,1], FUN =  function(tmx){
         dtx <- eval(as.name(df_name))
         assign("timex", dtx[, tmx])
         range(timex)
 })
cr_rngs_S2

tbls_S2 <-  sapply(cr_mtx[,2], FUN =  function(evnt){
         dtx <- eval(as.name(df_name))
         assign("event", dtx[, evnt])
         table(event)
 })
rownames(tbls_S2)[2] <- "event"
tbls_S2



cr_varnms <- paste


# Step 3: Create `init_split` and `foldid` variables.







