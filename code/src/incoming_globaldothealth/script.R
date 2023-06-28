# install.packages("devtools")  # if you do not have devtools
# devtools::install_github("globaldothealth/list/api/R")
if(ctry=="NA"){
  cases <- get_cases(api_key, disease = "covid-19")
} else {
  cases <- get_cases(api_key, disease = "covid-19", country = ctry)
}

cases <- cases %>%
  group_by(events.confirmed.date, location.administrativeAreaLevel1, location.administrativeAreaLevel2, location.administrativeAreaLevel3) %>%
  summarise(count = n())

saveRDS(cases, "dat.rds")
