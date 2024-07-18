 create_cc_weights <- function(data, subcohort, case, n_total){
   ## n_total = nrow(data)
   n_subcohort = sum(data$subcohort)
   ## n_non_cases_overall = sum(data$case == 0)
   n_non_cases_overall <- n_total - sum(data$case == 1)

 # Calculate various C-C weights
  
 data <- data  %>%
  mutate(
    Self = case_when(
        subcohort == 1 ~ 1,
        subcohort == 0 & case == 1 ~ n_total / n_subcohort,
        TRUE ~ 0 # Non-cases not in the subcohort should not have weights assigned
        ),
  
    SelfPrentice = case_when(
      subcohort == 1 & case == 0 ~ 1,
      subcohort == 1 & case == 1 ~ 1 + n_subcohort / n_non_cases_overall,
      subcohort == 0 & case == 1 ~ n_subcohort / n_non_cases_overall,
      TRUE ~ 0 # Cases that are not part of the subcohort have a calculated weight
    ),
    
     BorganI = case_when(
        subcohort == 1 ~ 1,
        subcohort == 0 & case == 1 ~ n_total / n_subcohort,
        TRUE ~ 0  # Non-cases outside of the subcohort typically not assigned weights
    )
  )
 }
