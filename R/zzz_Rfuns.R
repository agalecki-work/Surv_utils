funNms <- c(
  "SurvSplit_truncate",
  "create_cr_vars2",
  "create_foldid_vars",
  "create_srs_folds",
  "create_cch_folds", 
  "list_added_components",
  "create_cch_weights"
)

funNmsR  <- paste0(funNms,".R") 
lapply(funNmsR, FUN= function(src) source(paste0( "./R/", src)))

rm(funNmsR)
