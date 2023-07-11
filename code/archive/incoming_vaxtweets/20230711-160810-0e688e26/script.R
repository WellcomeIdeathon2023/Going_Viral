df <- read.csv("vax_tweets.csv", stringsAsFactors = FALSE)

df <- df %>% mutate(user_in_uk = grepl("United Kingdom|GB|UK|England|London", user_location))

df <- df %>% mutate(date = lubridate::dmy_hm(date))

saveRDS(df, "dat.rds")

rmarkdown::render("blurb.Rmd")
