
# source("061accord-update-subcohort.R") # This file

rm(list= ls())

#--- Create mandatory `df_initInfo` list and `work_data' dataframe
source("060accord_olink_analytical_dataset040323.R") 
#print(df_initInfo)


#---- Create `Project_Info` list by modifying  `Project_initInfo`  ---------
print(Project_initInfo)

prj <- Project_initInfo              # Copy `Project_initInfo` list
#prj$CCH_Info <- NULL                # CCH info ignored
prj$dfin_Info$cfilter  <- "FEMALE == 1"  # Subset of Subcohort
prj$dfin_Info$cfilter_comment    <- "Females only"
prj$dfin_Info$time_horizon <- c(10, 9.99)  # if vector with two elements use second element to define tm_cut (Inf no truncation)
Project_Info <- prj

#==== Typically no changes, below

source("./src/process_work_data.R")


train_data <- work_data %>% filter(initSplit == 1)
val_data  <- work_data %>% filter(initSplit == 0)

## if (!is.null(val_data))

mod_cxterms1 <- c("BM1", "log(BM1)")

BM1_train_spline3 <- ns(train_data$BM1,  df =3) #  df = No of knots +  degrees
attributes(BM1_train_spline3)


BM1_train_spline3_knots  <- attr(BM1_train_spline3, "knots") # 

BM1_val_spline3 <- ns(val_data$BM1, knots = BM1_train_spline3_knots)

if (length(tv_slevels >= 3)){
# Expand Data Using finegray for event type 1
  fg_data <- expand_data_finegray(train_data, tvar_Info = tvar_Info) # , etype = 1)
}



form1 <- formula(. ~  bs(BM1, df=3) + bs(BM2, df=3))




mod1_mtx <- model.matrix(form1, data = train_data)

BM1_spline <-  bs(train_data$BM1, df =3)


print("*end")


#initSplit_select <- 1  #  
#source("./src/add_aux_vars.R")



keep_objects <- c("accord", "accord_subcohort", "df_Info")
# print(df_Info)

# Cleanup (No changes below) 
ls_objects <- ls()
rm_objects  <- c(setdiff(ls_objects, keep_objects), "ls_objects")
#rm(list = rm_objects)
rm(rm_objects)
