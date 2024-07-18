funNms <- c(
  "SurvSplit_truncate",
  "create_cr_vars",
  "create_foldid_vars"
)

funNmsR  <- paste0(funNms,".R") 
lapply(funNmsR, FUN= function(src) source(paste0( "./R/", src)))

rm(funNmsR)
