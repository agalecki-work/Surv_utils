# 
# source("030rott_01data.R")

rm(list = ls())


require(dplyr)
require(survival)

#=========================  Data rotterdam (1) =================
# https://github.com/danielegiardiello/Prediction_performance_survival/blob/main/01_predsurv_minimal.R

# Data and recoding ----------------------------------
# Development data

rotterdam <- survival::rotterdam
rotterdam$ryear <- rotterdam$rtime/365.25  # time in years
rotterdam$rfs <- with(rotterdam, pmax(recur, death)) #The variable rfs is a status indicator, 0 = alive without relapse, 1 = death or relapse.

# Fix the outcome for 43 patients who have died but 
# censored at time of recurrence which was less than death time. 
# The actual death time should be used rather than the earlier censored recurrence time.

rotterdam$ryear[rotterdam$rfs == 1 & 
                  rotterdam$recur == 0 & 
                  rotterdam$death == 1 & 
                  (rotterdam$rtime < rotterdam$dtime)] <- 
  
  rotterdam$dtime[rotterdam$rfs == 1 &
                    rotterdam$recur == 0 & 
                    rotterdam$death == 1 & 
                    (rotterdam$rtime < rotterdam$dtime)]/365.25  
   
  rotterdam$dyear <- rotterdam$dtime/365.25  # <-  inserted 

# variables used in the analysis
pgr99 <- quantile(rotterdam$pgr, .99, type = 1) # there is a large outlier of 5000, used type=1 to get same result as in SAS
rotterdam$pgr2 <- pmin(rotterdam$pgr, pgr99) # Winsorized value
nodes99 <- quantile(rotterdam$nodes, .99, type = 1) 
rotterdam$nodes2 <- pmin(rotterdam$nodes, nodes99) # NOTE: winsorizing also continuous node?

rotterdam$csize <- rotterdam$size           # categorized size
rotterdam$cnode <- cut(rotterdam$nodes, 
                       c(-1,0, 3, 51),
                       c("0", "1-3", ">3"))   # categorized node
rotterdam$grade3 <- as.factor(rotterdam$grade)
levels(rotterdam$grade3) <- c("1-2", "3")

# Save in the data the restricted cubic spline term using Hmisc::rcspline.eval() package

# Continuous nodes variable
rcs3_nodes <- Hmisc::rcspline.eval(rotterdam$nodes2, 
                            knots = c(0, 1, 9)) 
attr(rcs3_nodes, "dim") <- NULL
attr(rcs3_nodes, "knots") <- NULL
rotterdam$nodes3 <- rcs3_nodes  # Dev data  

# PGR added
rcs3_pgr <- Hmisc::rcspline.eval(rotterdam$pgr2, 
                          knots = c(0, 41, 486)) # using knots of the original variable (not winsorized)
attr(rcs3_pgr, "dim") <- NULL
attr(rcs3_pgr, "knots") <- NULL
rotterdam$pgr3 <- rcs3_pgr

# Much of the analysis will focus on the first 5 years: create
#  data sets that are censored at 5
temp <- survSplit(Surv(ryear, rfs) ~ ., data = rotterdam, cut = 5,
                  episode="epoch")
rott5 <- subset(temp, epoch == 1)  # only the first 5 years
# Relevel
rott5$cnode <- relevel(rotterdam$cnode, "0")


# Validation data

gbsg$ryear <- gbsg$rfstime/365.25
gbsg$rfs   <- gbsg$status           # the GBSG data contains RFS
gbsg$cnode <- cut(gbsg$nodes, 
                  c(-1,0, 3, 51),
                  c("0", "1-3", ">3"))   # categorized node
gbsg$csize <- cut(gbsg$size,  
                  c(-1, 20, 50, 500), #categorized size
                  c("<=20", "20-50", ">50"))
gbsg$pgr2 <- pmin(gbsg$pgr, pgr99) # Winsorized value of PGR
gbsg$nodes2 <- pmin(gbsg$nodes, nodes99) # Winsorized value of continuous nodes
gbsg$grade3 <- as.factor(gbsg$grade)
levels(gbsg$grade3) <- c("1-2", "1-2", "3")

# Restricted cubic spline 
# Continuous nodes
rcs3_nodes <- Hmisc::rcspline.eval(gbsg$nodes2, knots = c(0, 1, 9))
attr(rcs3_nodes, "dim") <- NULL
attr(rcs3_nodes, "knots") <- NULL
gbsg$nodes3 <- rcs3_nodes

# PGR
rcs3_pgr <- Hmisc::rcspline.eval(gbsg$pgr2, knots = c(0, 41, 486))
attr(rcs3_pgr, "dim") <- NULL
attr(rcs3_pgr, "knots") <- NULL
gbsg$pgr3 <- rcs3_pgr


# Much of the analysis will focus on the first 5 years: create data censored at 5 years
gbsg$status <- NULL  # Avoid duplicate name
temp <- survSplit(Surv(ryear, rfs) ~ ., data = gbsg, cut = 5,
                  episode ="epoch")
gbsg5 <- subset(temp, epoch == 1)
gbsg5$cnode <- relevel(gbsg$cnode, "0")
rm(temp, rcs3_nodes,nodes99, pgr99, rcs3_pgr)

# data_Info


tvars1 <- c("ryear", "rfs")             #  Variables' names used to create Surv objects
tvars2 <- c("dyear", "death")
tvars_all <- rbind(tvars1, tvars2)
colnames(tvars_all) <- c("timevar", "eventvar")
tvars_all 

colnames(tvars_all) <- c("timevar", "eventvar")
tvars_all 

rm(tvars1, tvars2)           # Cleanup

# Mandatory list `dfAll_info`
dfAll_Info <- list(
   current_folder = getwd(),
   url            = "https://github.com/danielegiardiello/Prediction_performance_survival/blob/main/01_predsurv_minimal.R",
   datain_script  = "003rott_01data",  # R script that creates data frames 
   datain_basename = c("survival::rotterdam", "survival::gbsg"),
   datain_extension = NULL, 
   dfnms_all   = c("rott5", "gbsg5"),  # Data frames created by this script
   df_name    = "Place holder", # One or two data frames (training and/or validation) selected
   id          = "pid",
   tvars_all   = tvars_all,    # Matrix with  variables' names used to create Surv objects
   time_horizon = 5,           # 5 years 
   CCH_data    = FALSE
 )
rm(tvars_all)
print(dfAll_Info)

