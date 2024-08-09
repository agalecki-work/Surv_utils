#======  Update `dfin_name` data frame with auxilary variables
source("./R/zzz_Rfuns.R")    # R functions loaded
if (is.null(df_Info$CCH_data)) df_Info$CCH_data <- FALSE
if (df_Info$CCH_data & !exists("dfCCH_Info"))  dfCCH_Info <- dfCCH_initInfo


keep_Allvars <- df_Info$id 

#---- Step 0: Check input info

# Make sure no new components created in `df_Info` list compared to `df_initInfo`
  nms0 <- names(df_initInfo)
  nms1 <- names(df_Info)
  added_df_Info_components <- setdiff(nms1, nms0)
  if (length(added_df_Info_components) ==0){
    txt <- "---  df_initInfo vs  df_Info. No added components  ... OK"
    } else {
    txt <- "---  df_initInfo vs  df_Info. Added components  ...  Error"
    }
 message(txt)

 
# Unpack df_Info
nms0 <-  names(df_Info)
for (nm in nms0) assign(nm, df_Info[[nm]], envir = .GlobalEnv)


# unpack dfCCH_Info
if (CCH_data){
  # Make sure no new components created in `dfCCH_Info` list
  nms0 <- names(dfCCH_initInfo)
  nms1 <- names(dfCCH_Info)
  added_dfCCH_Info_components <- setdiff(nms1, nms0)
  for (nm in nms0) assign(nm, dfCCH_Info[[nm]], envir = .GlobalEnv)
  ### tvars <- dfCCH_Info$CCH_tvars
} # if (CCH_data)
 

# Define tm_cut
tm_cut <- if (length(time_horizon) == 2) time_horizon[2] else time_horizon[1]

# common_vars <- intersect(keep_xvars, colnames(eval(as.name(dfin_name))))

## Process dfin_name original df

 df_no   <- 1
 dfnew_name <-  if (length(dfin_name) == 2)  dfin_name[2] else character(0)

 message("=====> # data frame `", dfin_name, "`-> `", dfnew_name,  "` modified -----")
 
 
#--- source("./src/add_aux_vars_main.R")

message("==>==>==> # Data frame name: `", dfin_name, "`-> `", dfnew_name,  "` modified -----")

dfin_datax <- eval(as.name(dfin_name)) # working copy
tvars_vec <- tvar_select$tvars

keep_dfinvars <- c(id, tvars_vec, keep_xvars) 
dfin_datax <- dfin_datax %>% select(all_of(unique(keep_dfinvars)))  # Select xvars
dfdim_txt  <- paste(dim(dfin_datax), collapse =", ")
message("---  Dim (nrows, ncols) in original data: ", dfdim_txt) 

#----- prep steps

message(paste0("===> Surv vars for the event of interest: ", tvars_vec[1], ", ",  tvars_vec[2]))
message(paste0("--- CCH_data: ", CCH_data))

ntvarsx <- length(tvar_select$svalues) # 2 or 3

txt0  <- if (ntvarsx ==2) "NO" else paste0("YES")
message(paste0("--- Competing risk: ", txt0))


# --- Checking whether variables are present
 varNms <- colnames(dfin_datax)
 vars_not_found <- if (CCH_data) {
          setdiff(c(tvars_vec, id, subcohort, cch_case),varNms) 
       } else {
          setdiff(c(tvars_vec, id),varNms) 
       }
 if (length( vars_not_found) ==0){
    message("---  Vars not found (blank expected):  ... OK")
    } else {
    message("---  Vars not found (blank expected):", vars_not_found, "  ...???")
    }
 
#---- Step 1:  cfilter applied

message(paste0("---> Step1: Filter is defined as: ", cfilter)) 
if (length(cfilter) > 0){
  dfdim <- paste(dim(dfin_datax), collapse =", ")
  message("------  Dim (nrows, ncols _before_ filter): ", dfdim) 
  cfilter_stmnt <- paste0("dfin_datax %>% filter(", cfilter,")")
  assign("dfin_datax", eval(parse(text= cfilter_stmnt)))
  dfdim <- paste(dim(dfin_datax), collapse =",")
  message("------  Dim (nrows, ncols _after_ filter): ", dfdim)
  rm(cfilter_stmnt)
} else {
  dfdim <- paste(dim(dfin_datax), collapse =",")
  message("---  Dim filter is NULL:", dfdim) 
} # if cfilter

# ---- Step 1a: Filter out non-cases outside of subcohort
if (CCH_data){
  cstmnt <- paste0("ifelse(", tvars_vec[2],"==1, 1,0)")
  dfin_datax <- within(dfin_datax,{
    CCH_ucase <- eval(parse(text = cstmnt))
  })
 #  cch_cstmnt <- paste0("dfin_datax %>% filter(",  subcohort, "|", cch_case, ")")
  cch_cstmnt <- paste0("dfin_datax %>% filter(",  subcohort, "| CCH_ucase)")
  
  dfin_datax <- eval(parse (text=cch_cstmnt))
  dfdim_txt  <- paste(dim(dfin_datax), collapse =", ")
  message("---> Step1a: Dim (nrows, ncols)", dfdim_txt) 
} else {
 message("---> Step 1a is skipped,because `CCH_data` is FALSE")
}


#---- Step 2: Truncate time time variable included in `tvars_vec` 

message("---> Step 2: Time horizon :=", time_horizon[1], ", tm_cut =", tm_cut) 

if (is.finite(time_horizon[1])){
 # Before truncating time in df
 rngs_beforeS1 <-  sapply(tvars_vec[1], FUN =  function(tmx){
         dtx_temp <- dfin_datax
         assign("timex", dtx_temp[, tmx])
         range(timex)
  })
 max_time <- max(rngs_beforeS1[2.])
 message("---  Max time _before_ truncation :=", round(max_time, digits=3)) 

 postfix <- paste0("_th", time_horizon[1])

 dfin_datax <- SurvSplit2_truncate(dfin_datax, tvars_vec, time_horizon = tm_cut, postfix = postfix )
 
 tvars_vec <- paste(tvars_vec, postfix, sep="") #tvars_vec adjusted

 # After truncating time

 rngs_S1 <-  sapply(tvars_vec[1], FUN =  function(tmx){
         dtx_temp <- dfin_datax
         assign("timex", dtx_temp[, tmx])
         range(timex)
 })
 max_time <- max(rngs_S1[2.])
 message("---  Max time _after_ truncation :=", round(max_time, digits =3)) 
 
#rngs_S1

rm(max_time, rngs_S1, rngs_beforeS1) 
} else{

 message("--- Time_horizon is Infinity (Time truncation NOT done)   ... OK ")  
} # if (is.finite(time_horizon[1])


if (!CCH_data){
   keep_Allvars <- c(keep_Allvars, tvars_vec)
   } else {
   keep_Allvars <- c(keep_Allvars, subcohort, cch_case, tvars_vec)
   }
# print(keep_Allvars)


