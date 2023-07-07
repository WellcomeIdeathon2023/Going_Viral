# install.packages("devtools")  # if you do not have devtools
# devtools::install_github("globaldothealth/list/api/R")
# Sys.setenv(API_KEY="<your-api-key>")
if(ctry=="NA"){
  cases <- globaldothealth::get_cases(Sys.getenv("API_KEY"), disease = "covid-19")
} else {
  cases <- globaldothealth::get_cases(Sys.getenv("API_KEY"), disease = "covid-19", country = ctry)
}

cases <- cases %>%
  dplyr::group_by(events.confirmed.date, location.administrativeAreaLevel1, location.administrativeAreaLevel2, location.administrativeAreaLevel3) %>%
  dplyr::summarise(count = n())

saveRDS(cases, "dat.rds")
