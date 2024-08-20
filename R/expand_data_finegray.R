expand_data_finegray <- function(data, tvar_Info){  # , etype) {
  tv_tvars <- tvar_Info$tnms
  tv_slevels <- tvar_Info$slevels
  tv_slabels <- tvar_Info$slabels
 print(tv_slevels)
  ff <- data[, tv_tvars[2]]
  print(tv_tvars[2])
  print(head(ff))
  if (!is.factor(ff)){
      ffx <- factor(ff, levels = tv_slevels, labels = tv_slabels)
      print(head(ffx))

      data[, tv_tvars[2]] <- ffx
  }
  cform <- paste0("Surv(", tv_tvars[1], ", ", tv_tvars[2], ") ~ .")
  finegray_data <- finegray(as.formula(cform), data = data, etype =tv_slabels[2])
  return(finegray_data)
}