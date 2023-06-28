# install.packages("devtools")  # if you do not have devtools
# devtools::install_github("globaldothealth/list/api/R")

cases <- get_cases(api_key, disease = "covid-19")

saveRDS(cases, "dat.rds")

