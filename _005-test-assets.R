rm (list= ls())
data_path <- "./data/"

source("./data/rott_01data.R")
source("./data/rott_02data.R")
source("./data/cric_olinknpx_112023_v1_imputed0.R")

source("./R/zzz_Rfuns.R")

ls()

mod_Info <- list(
  wght     = character(0),        # weight variable (if any)
  id       = "MASKID",
  cxterms1 = c("AGE", "log(AGE)"), # simple terms
  cx_splines = "accord_splines.R", # Script with splines  
  tt_split_length  = 0.1          # 0.1, 0.01 Length of tt_split_interval used to create expanded data
)

train_data <- work_data %>% filter(initSplit == 1)
val_data  <- work_data %>% filter(initSplit == 0)

## if (!is.null(val_data))

mod_cxterms1 <- c("BM1", "log(BM1)")  # Simple terms

#----  Create splines
#
# Ex  train_BM1_spline  <- ns(train_data$BM1,  df = 3)
#   BMI_spline_knots  <- attr(train_BM1_spline, "knots")
#    val_BM1_spline    <- ns(val_data$BM1,  knots = BMI_spline_knots)
#



#initSplit_select <- 1  #  
#source("./src/add_aux_vars.R")


svar <- "BM1"
df   <- 3
prfix <- "train"  # val

ns_spline <- function
cspline <- "ns ( ${data} $ ${var} , $D
train_cxterms2 <- c("ns(train_data$BM1,  df = 3)", "ns(train_data$BM2,  df =3)") # Composite terms, e.g. splines
# val_cxterms2   <- c("ns(val_data$BM1,  knots = attr(BM1_train_spline3, "knots") )", "ns(val_data$BM2,  df =3)") 
cxterms <- c(mod_cxterms1, train_cxterms2)
cform_RHS <- paste(cxterms, sep= "", collapse ="+")
cform <- paste0( "~ 0 + ", cform_RHS)

for (i in 1:length(mod_cxterms2)){
 nsi  <- train_cxterms2[i]  # Ex. "ns(train_data$BM1,  df =3)"
 nsi2 <- str_replace(nsi, stringr::fixed("train_data$"), "")
 cformi  <- as.formula(paste0("~ 0 + ", nsi2)) # "~ 0 + ns(BM1,  df =3)" 
 train_splinei <- eval(parse(text = nsi)) #  Creates spline basis matrix using `train_data`
 train_knotsi <- attr(train_splinei, "knots")
 train_Xmtxi  <- model.matrix(as.formula(cformi), data =train_data)
 nsi3 <- str_replace(nsi, stringr::fixed("train_data$"), "val_data$")
 nsi3 <- str_replace(nsi3, stringr::fixed(","
 val_splinei  <-
 # assign(nmi, model.matrix(as.formula(cformi), data =train_data))
}


train_termsf <- model.matrix(as.formula(cform), data = train_data)

BM1_train_spline3 <- ns(train_data$BM1,  df =3) #  df = No of knots +  degrees
attributes(BM1_train_spline3)

BM1_train_spline3_knots  <- attr(BM1_train_spline3, "knots") # 

BM1_val_spline3 <- ns(val_data$BM1, knots = BM1_train_spline3_knots)

if (length(tv_slevels >= 3)){
  message("====> data for competing risks for: ", tv_tnms[1], " finegray() applied" )
  message("--- `train_data` ", nrow(train_data), "x", ncol(train_data)) 
  # Expand Data Using finegray for event type 1
  train_fgdata <- expand_data_finegray(train_data, tvar_Info = tvar_Info) #
  message("--- `train_fgdata` ", nrow(train_fgdata), "x", ncol(train_fgdata)) 

  if (!is.null(val_data)){
    message("---  `val_data` ", nrow(val_data), "x", ncol(val_data)) 
    val_fgdata <- expand_data_finegray(val_data, tvar_Info = tvar_Info) #
     message("--- `val_fgdata` ", nrow(val_fgdata), "x", ncol(val_fgdata)) 

  } # !is.null(val_data))
  
  #cox_model1 <- coxph(Surv(fgstart, fgstop, fgstatus) ~ age +
  #                   age_spline_1 + age_spline_2 + age_spline_3 + age_spline_4,
  #                   data = fg_data)
  #cox.zph(cox_model1)

  
}



form1 <- formula(. ~  bs(BM1, df=3) + bs(BM2, df=3))




mod1_mtx <- model.matrix(form1, data = train_data)

BM1_spline <-  bs(train_data$BM1, df =3)


print("*end")

