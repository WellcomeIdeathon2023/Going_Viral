# Set seed
set.seed(1)

sentiment_vec <- tidytext::get_sentiments("bing")
topic_vec <- c("COVID", "COVI19", "COVID-19", "vaccination", "vaccines", "infection", "isolation", "quarantine", "long COVID", "protecting my family")
institution_vec <- c("the government", "my doctor", "my family", "my community", "my church", "my partner", "politicians")

generate_interview_statement <- function(sentiment_vec, topic_vec, institution_vec){
  sent <- sample(sentiment_vec$word[!grepl("ly|ing", sentiment_vec$word)], 1)
  top <- sample(topic_vec, 1)
  inst <- sample(institution_vec, 1)
  dodont <- sample(c("do", "do not"), 1)
  
  paste0("I am ", sent, " about ", top, " and I ", dodont, " think my views are heard by ", inst, ".")
}

int <- NULL
for(i in 1:100){
  int[i] <- generate_interview_statement(sentiment_vec, topic_vec, institution_vec)
}

# add random dates
date_range <- lubridate::as_date(lubridate::dmy("01-09-2020"):lubridate::dmy("31-12-2020"))

df <- data.frame(interview=int,
                 date = sample(date_range, size=100, replace = TRUE))

saveRDS(df, "dat.rds")

for_website = df[c(17,14),]
for_website_json = rjson::toJSON(for_website)
write(for_website_json, "quotes.json")

rmarkdown::render("blurb.Rmd")
