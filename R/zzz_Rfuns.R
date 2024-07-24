funNms <- c(
  "SurvSplit_truncate",
  "create_cr_vars",
  "create_foldid_vars",
  "create_srs_folds",# CCH study needed 
  "list_added_components",
  "create_cch_weights"
)

funNmsR  <- paste0(funNms,".R") 
lapply(funNmsR, FUN= function(src) source(paste0( "./R/", src)))

rm(funNmsR)
