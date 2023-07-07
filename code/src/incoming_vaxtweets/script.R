df <- read.csv("vax_tweets.csv", stringsAsFactors = FALSE)

df <- df %>% dplyr::mutate(user_in_uk = grepl("United Kingdom|GB|UK|England|London", user_location))

df <- df %>% dplyr::mutate(date = lubridate::dmy_hm(date))

saveRDS(df, "dat.rds")
