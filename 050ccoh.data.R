## The complete Wilms Tumor Data 
## (Breslow and Chatterjee, Applied Statistics, 1999)
## subcohort selected by simple random sampling.
##

library(survival)  

data(nwtco)   # The complete Wilms Tumor Data, nobs= 4028
total_cohort_size <- nrow(nwtco) 
subcoh <- nwtco$in.subcohort
selccoh <- with(nwtco, rel==1|subcoh==1)
table(selccoh) # 2874 + 486
table(subcoh)  # 668 in subcohort (668/4028 = 16.6% ~ 1/6)
table(subcoh, rel=nwtco$rel) # All subjects including n=2874 non-cases outside of subcohort


# Case cohort data stored in `ccoh.data` (nobs = 1154, non-cases outside of subcohort excluded)
ccoh.data <- nwtco[selccoh,]
ccoh.data$subcohort <- subcoh[selccoh]
## central-lab histology 
ccoh.data$histol <- factor(ccoh.data$histol,labels=c("FH","UH"))
## tumour stage
ccoh.data$stage <- factor(ccoh.data$stage,labels=c("I","II","III","IV"))
ccoh.data$age   <- ccoh.data$age/12 # Age in years

rm(subcoh, selccoh)

data_Info <- list(     
     complete_data_label = "The complete Wilms Tumor Data: Case-cohort design (nobs =4028)",
     data_note  = "subcohort selected by simple random sampling",
     data_ref   = "Breslow and Chatterjee, Applied Statistics, 1999"
)

     