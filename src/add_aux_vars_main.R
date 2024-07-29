# Called by `add_aux_vars.R` script
# Note: df_Info list unpacked
ntvars <- nrow(tvars_all)


 varNms <- colnames(eval(as.name(dfin_name)))
 vars_not_found <- if (CCH_data) {
       setdiff(c(as.vector(tvars_all), id, subcohort, cch_case),varNms) 
       } else {
          setdiff(c(as.vector(tvars_all), id),varNms) 
       }
 tmp_nm <- paste0("vars_not_found",df_no)
 assign(tmp_nm, vars_not_found, envir = .GlobalEnv)
 if (length( vars_not_found) ==0){
    message("--- # Vars not found (blank expected):  ... OK")
    } else {
    message("--- # Vars not found (blank expected):", eval(as.name(tmp_nm)))
 
    }
 rm(tmp_nm)
 if (length(vars_not_found) == 0) rm(vars_not_found)
 
#---- Step :  Filter
if (length(cfilter) > 0){
  message("---> # Filter ", cfilter, " applied")
  dfdim <- paste(dim(eval(as.name(dfin_name))), collapse =",")
  message("--- # Dim (before filter): ", dfdim) 
  cfilter_stmnt <- paste0(dfin_name, " %>% filter(", cfilter,")")
  assign(dfin_name, eval(parse(text= cfilter_stmnt)))
  dfdim <- paste(dim(eval(as.name(dfin_name))), collapse =",")
  message("--- # Dim (after filter): ", dfdim)
  rm(cfilter_stmnt)
} else {
  dfdim <- paste(dim(eval(as.name(dfin_name))), collapse =",")
  message("--- # Dim filter is NULL:", dfdim) 
}
rm(dfdim)


#---- Step 1: Truncate time for all time variables included in `tvars_all` matrix

message("---> # Time horizon :=", time_horizon[1]) 

# Before truncating time in df
rngs_beforeS1 <-  sapply(tvars_all[,1], FUN =  function(tmx){
         dtx_temp <- eval(as.name(dfin_name))
         assign("timex", dtx_temp[, tmx])
         range(timex)
 })
max_time <- max(rngs_beforeS1[2.])
message("--- #  Max time _before_ truncation :=", max_time) 

tbls_beforeS1 <-  sapply(tvars_all[,2], FUN =  function(evnt){
         dtx_temp <- eval(as.name(dfin_name))
         assign("event", dtx_temp[, evnt])
         table(event)
 })
#tbls_beforeS1


for (i in 1:ntvars){
 assign(dfin_name, SurvSplit_truncate(eval(as.name(dfin_name)), tvars_all[i,], tm_cut), envir=.GlobalEnv)
}


# After truncating time

rngs_S1 <-  sapply(tvars_all[,1], FUN =  function(tmx){
         dtx_temp <- eval(as.name(dfin_name))
         assign("timex", dtx_temp[, tmx])
         range(timex)
 })
max_time <- max(rngs_S1[2.])
message("--- #  Max time _after_ truncation :=", max_time) 
 
#rngs_S1

tbls_S1 <-  sapply(tvars_all[,2], FUN =  function(evnt){
         dtx_temp <- eval(as.name(dfin_name))
         assign("event", dtx_temp[, evnt])
         table(event)
 })
#tbls_S1
rm(max_time, rngs_S1, tbls_S1, rngs_beforeS1, tbls_beforeS1) 

if (!CCH_data){
   keep_Allvars <- c(keep_Allvars, as.vector(tvars_all))
   } else {
   keep_Allvars <- c(keep_Allvars, subcohort, cch_case, as.vector(CCH_tvars))
   }

#---??? Step 2: Create competing risk variables (cr_*)

if (ntvars > 1){
 message("---> `cr` variables for CR analysis created (ntvars :=", ntvars, ")")

 ncrvars <- ntvars-1  # Last row is competing risk

 for (i in 1:ncrvars){
  dtx_temp <- eval(as.name(dfin_name)) # df updated 
  assign(dfin_name, 
          create_cr_vars2(dtx_temp, tvars_all[i,], tvars_all[ncrvars+1 ,] ), 
          envir=.GlobalEnv)
 }

 cr_vars0 <- tvars_all[ -ntvars,] # Last row omitted

 cr_mtx0 <- paste("cr_", cr_vars0, sep="")
 cr_mtx <- matrix(cr_mtx0, ncol =2)
 colnames(cr_mtx) <- c("cr_time", "cr_event")
 nms <- rownames(tvars_all)
 rownames(cr_mtx) <- nms[-ntvars]
 # cr_mtx

 cr_rngs_S2 <-  sapply(cr_mtx[,1], FUN =  function(tmx){
         dtx_temp <- eval(as.name(dfin_name))
         assign("timex", dtx_temp[, tmx])
         range(timex)
 })
 # cr_rngs_S2

 tbls_S2 <-  sapply(cr_mtx[,2], FUN =  function(evnt){
         dtx_temp <- eval(as.name(dfin_name))
         assign("event", dtx_temp[, evnt])
         table(event)
 })
 rownames(tbls_S2)[2] <- "event"
 # tbls_S2
 } else {
 message("---> `cr` variables for competing risk analysis _not_ created (because ntvars :=", ntvars, ")")

}
if (!CCH_data) keep_Allvars <- c(keep_Allvars, as.vector(cr_mtx))


#--- Step 3: Create weight variables for data from C-CH study in dfin_name : Self, SelfPrentice, BorganI

if (CCH_data){ # C-C data only
  message("---> CCH_data is ", CCH_data, " => CCH weight variables created")
  assign(dfin_name, 
      create_cch_weights(as.name(dfin_name), as.name(subcohort), as.name(subcohort), total_cohort_size),
      envir=.GlobalEnv)
  keep_Allvars <- c(keep_Allvars,"w_Self","w_SelfPrentice", "w_BorganI") 
} else  message("---> CCH_data is ", CCH_data, " => CCH weight variables _not_ created")
 


# Step 4: Create `init_split` and `foldid` variables.

if (length(initSplit) !=0){

if (CCH_data){
  message("---> CCH data `create_cch_folds()` functiom used (not yet). Vars `initSplit`, `foldid` created")

 } else {
  message("---> SRS data `create_srs_folds()` functiom used. Vars `initSplit`, `foldid` created")
  assign(dfin_name, create_srs_folds(eval(as.name(dfin_name)), initSplit, nfolds))
}
  keep_Allvars <- c(keep_Allvars, "init_split", "foldid") 

}


keep_Allvars <- unique(c(keep_Allvars, df_Info$keep_vars))





