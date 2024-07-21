
ntvars <- nrow(tvars_all)


 varNms <- colnames(eval(as.name(df_name)))
 vars_not_found <- if (CCH_data) {
       setdiff(c(as.vector(tvars_all), id, subcohort, cch_case),varNms) 
       } else {
          setdiff(c(as.vector(tvars_all), id),varNms) 

       }
 tm_cut <- if (length(time_horizon) ==2) time_horizon[2] else time_horizon[1]

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


#--- Step 3: Create weight variables for C-C study in df_name : Self, SelfPrentice, BorganI

if (CCH_data){ # C-C data only
  assign(df_name, 
      create_cch_weights(as.name(df_name), as.name(subcohort), as.name(subcohort), total_cohort_size),
      envir=.GlobalEnv)
}


# Step 4: Create `init_split` and `foldid` variables.








