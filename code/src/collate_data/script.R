vaxtweets_dat <- readRDS("vaxtweets_dat.rds")
globaldothealth_dat <- readRDS("globaldothealth_dat.rds")
vaccinationcoverage_dat <- readRDS("vaccinationcoverage_dat.rds")

# filter to UK only
vaxtweets_dat <- vaxtweets_dat %>% filter(user_in_uk)

# try to link locations
loc1 <- unique(globaldothealth_dat$location.administrativeAreaLevel1)
loc2 <- unique(globaldothealth_dat$location.administrativeAreaLevel2)
loc3 <- unique(globaldothealth_dat$location.administrativeAreaLevel3)
loc2 <- loc2[!is.na(loc2)]
loc3 <- loc3[!is.na(loc3)]

vaxtweets_dat <- vaxtweets_dat %>% rowwise() %>%
  mutate(tidy_loc1 = get_location(user_location, loc1)) %>%
  mutate(tidy_loc2 = get_location(user_location, loc2)) %>%
  mutate(tidy_loc3 = get_location(user_location, loc3)) %>%
  mutate(tidy_loc1 = ifelse("London" %in% user_location, "London", tidy_loc1))

# sentiments
vax_unnest <- vaxtweets_dat %>%
  unnest_tokens(word, text) 

sent <- get_sentiments("bing")

# generate wordclouds
plot_wordcloud(vax_unnest, NULL, NULL, sent)
plot_wordcloud(vax_unnest, "London", NULL, sent)
plot_wordcloud(vax_unnest, "London", 2020, sent)
plot_wordcloud(vax_unnest, "London", 2021, sent)
plot_wordcloud(vax_unnest, "London", 2022, sent)

# get sentiment over time by location to align with cases
p <- plot_sentiment_over_time(vax_unnest, sent, "London")
ggsave("sentiment_over_time_london.png", p)

p <- plot_sentiment_over_time(vax_unnest, sent, NULL)
ggsave("sentiment_over_time.png", p)

# finally save combined data
vax_sentiment <- vax_unnest %>%
  anti_join(get_stopwords(), by="word")%>%
  left_join(sent, by="word") %>%
  mutate(date = lubridate::date(date)) %>%
  group_by(date, sentiment, tidy_loc1) %>%
  summarise(sent_count = n())

combined_dat <- globaldothealth_dat %>% 
  mutate(date = events.confirmed.date) %>% 
  group_by(date, location.administrativeAreaLevel1) %>%
  summarise(case_count = sum(count, na.rm = TRUE)) %>%
  rename(tidy_loc1 = location.administrativeAreaLevel1) %>%
  full_join(vax_sentiment %>% filter(!is.na(sentiment)) %>% tidyr::pivot_wider(names_from=sentiment, values_from=sent_count))

# Filter data to 1st July 2020 to 22nd December 2020 as when have case data for London
combined_dat <- combined_dat %>%
  left_join(vaccinationcoverage_dat, by="date") %>% 
  filter(date > as.Date("2020-06-30") & date < as.Date("2020-12-23"))

saveRDS(combined_dat, "combined_dat.rds")

# comparison plot over time
p <- combined_dat %>%
  group_by(date) %>%
  summarise(case_count = sum(case_count, na.rm= TRUE), positive= sum(positive, na.rm = TRUE), negative=sum(negative, na.rm = TRUE)) %>%
  
  tidyr::pivot_longer(names_to = "type", values_to = "count", -date) %>%
  ggplot()+
  aes(x = date, y = count)+
  geom_line()+
  facet_wrap(type~., scales = "free", ncol = 1)

ggsave("sentiment_cases_over_time.png", p)


# Saves data as a json
combined_data_london = combined_dat %>% dplyr::filter(tidy_loc1 == "London")
collated_data_json = rjson::toJSON(combined_data_london)
write(collated_data_json, "collated_data_london.json")
