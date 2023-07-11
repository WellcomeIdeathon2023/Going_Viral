get_location <- function(user_location, loc){
  if(tolower(user_location) %in% tolower(loc)){
    loc[tolower(loc) %in% tolower(user_location)]
  } else {NA}
}

plot_wordcloud <- function(vax_unnest, loc1_name="London", yr=NULL, sent=sent){
  save_name <- paste0("wordcloud_", loc1_name, "_", yr, ".png")
  
  if(!is.null(loc1_name)) vax_unnest <- vax_unnest %>% filter(tidy_loc1==loc1_name)
  if(!is.null(yr)) vax_unnest <- vax_unnest %>% filter(lubridate::year(date)==yr)
  
  png(save_name, width=600, height=600)
  vax_unnest %>%
    anti_join(get_stopwords(), by="word")%>%
    left_join(sent, by="word") %>%
    filter(!word %in% c("https", "t.co", 1:100, "amp")) %>%
    filter(!grepl("vaccin|covid", word)) %>%
    filter(!is.na(sentiment)) %>%
    count(word, sentiment, sort=TRUE) %>%
    reshape2::acast(word ~ sentiment, value.var = "n", fill = 0) %>%
    comparison.cloud(colors = c("#ef8a47",  "#376795"),
                     max.words = 100) 
  
  dev.off()
}

plot_sentiment_over_time <- function(vax_unnest, sent, loc1_name=NULL){
  
  if(!is.null(loc1_name)) vax_unnest <- vax_unnest %>% filter(tidy_loc1==loc1_name)
  
  vax_sentiment <- vax_unnest %>%
    anti_join(get_stopwords(), by="word")%>%
    left_join(sent, by="word") %>%
    mutate(date = lubridate::format_ISO8601(date, precision = "ym")) %>%
    group_by(date, sentiment) %>%
    summarise(sent_count = n())
  
  vax_sentiment %>%
    filter(!is.na(sentiment)) %>%
    group_by(date) %>% mutate(tot_count = sum(sent_count, na.rm = TRUE)) %>% ungroup() %>%
    mutate(propn=sent_count/tot_count) %>% 
    ggplot()+
    aes(x = date, y = propn, fill = sentiment)+
    geom_col()+
    theme_minimal()+
    scale_fill_manual(values = c("#ef8a47",  "#376795"))+
    theme(axis.text.x = element_text(angle = 90, hjust=1), legend.position = "bottom")+
    labs(x = "Date", y="Proportion of tweet words")
}