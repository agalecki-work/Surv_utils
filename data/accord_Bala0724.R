xlsx_name <- "accord_Bala0724"

accord  <-read.xlsx(paste0(data_path, xlsx_name, ".xlsx"))

accord <- accord %>%
  mutate(stratm = case_when(
    BPTRIAL == 0 & GLYINT == 0 & FIBRATE == 0 ~ 1,
    BPTRIAL == 0 & GLYINT == 0 & FIBRATE == 1 ~ 2,
    BPTRIAL == 0 & GLYINT == 1 & FIBRATE == 0 ~ 3,
    BPTRIAL == 0 & GLYINT == 1 & FIBRATE == 1 ~ 4,
    BPTRIAL == 1 & GLYINT == 0 & BPINT == 0 ~ 5,
    BPTRIAL == 1 & GLYINT == 0 & BPINT == 1 ~ 6,
    BPTRIAL == 1 & GLYINT == 1 & BPINT == 0 ~ 7,
    BPTRIAL == 1 & GLYINT == 1 & BPINT == 1 ~ 8,
    TRUE ~ NA_integer_  # This handles any other cases that do not match the above conditions
  ))
  
##############################################################################################
# Split by alb status
normo <- filter(accord, UACR_gp1 == 1) #n=961
alb   <- filter(accord, UACR_gp1 == 2) #n=432
##############################################################################################

