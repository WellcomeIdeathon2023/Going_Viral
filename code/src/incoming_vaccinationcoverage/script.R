
df <- data.frame(date = lubridate::as_date(lubridate::dmy("01-09-2020"):lubridate::dmy("31-12-2020")))
df$coverage <- generate_vaccination_coverage(nsteps=nrow(df))

saveRDS(df, "dat.rds")

rmarkdown::render("blurb.Rmd")