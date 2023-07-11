# install.packages("devtools")  # if you do not have devtools
# devtools::install_github("globaldothealth/list/api/R")
# Sys.setenv(API_KEY="<your-api-key>")
if(ctry=="NA"){
  cases <- get_cases(Sys.getenv("API_KEY"), disease = "covid-19")
} else {
  cases <- get_cases(Sys.getenv("API_KEY"), disease = "covid-19", country = ctry)
}

cases <- cases %>%
  group_by(events.confirmed.date, location.administrativeAreaLevel1, location.administrativeAreaLevel2, location.administrativeAreaLevel3) %>%
  summarise(count = n())

saveRDS(cases, "dat.rds")

rmarkdown::render("blurb.Rmd")