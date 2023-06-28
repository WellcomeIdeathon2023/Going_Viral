# install.packages("devtools")  # if you do not have devtools
# devtools::install_github("globaldothealth/list/api/R")
if(ctry=="NA"){
  cases <- get_cases(api_key, disease = "covid-19")
} else {
  cases <- get_cases(api_key, disease = "covid-19", country = ctry)
}

#saveRDS(cases, "dat.rds")
write.csv(cases, "dat.csv", row.names = FALSE)
