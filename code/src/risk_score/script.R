# Loads all the different data sources 
comb_data = readRDS("combined_dat.rds")
rt = readRDS("rt.rds")
incidence = readRDS("incidence.rds")

# Choose date to make prediction for
if (date == "NA"){
  # Set date to maximum data in data set if not given
  report_date = max(case_dat$date) 
} else (
  report_date = as.Date(date, origin='1970-01-01')
)

# Select rt values for given date. 
rt = rt %>% 
  dplyr::filter(date == report_date) %>%
  dplyr::filter(tag != "60% CI") # Only consider 30 and 90% CIs for score metric
# Rt risk score contribution.  Plus one if lower 90% CI is above 1 and if lower
# 30% CI is above 1.(Basically +2 if 90% > 1 and +1 if only 30% > 1)
rt$score = ifelse(rt$lower > 1, 1, 0) 
rt = rt %>% dplyr::group_by(group) %>%
  dplyr::summarise(score = sum(score))

# Consider case projections for the next week
cases =  incidence %>% 
  dplyr::filter(date > report_date) %>% 
  dplyr::group_by(group) %>%
  dplyr::summarise(daily_mean = mean(median))
# Weekly forecast score contribution. Plus one if mean increase is greater than 
# 100 (probably would want to be population weighted), minus one if 0 cases are 
# forecast.  Could also incorporate if their are cases in the neighbouring regions.
cases$score = ifelse(cases$daily_mean > 100, 1, 
                     ifelse(cases$daily_mean == 0, -1, 0))
cases = cases %>% dplyr::select(-daily_mean)

# Consider vaccine coverage on the date of report
coverage = comb_data %>% 
  dplyr::select(date, tidy_loc1, coverage) %>%
  dplyr::filter(date >= report_date)
# If coverage is less than 25% increase risk score by 2, if less than 50% increase
# by 1. If vaccination is 95% or more decrease risk score by 1.
coverage$score = ifelse(coverage$coverage < 0.25, 2, 
                        ifelse(coverage$coverage < 0.5, 1, 
                        ifelse(coverage$coverage >= 0.95, -1, 0)))
coverage = coverage %>% 
  ungroup() %>% 
  dplyr::select(-coverage, -date)
names(coverage) = c("group", "score")

# Consider tweet sentiment. Not much data at the time period of the case data
# aggregated to level of London.  Therefore calculating mean ratio of positive
# to negative. With more data would be good to also include a metric of is
# ratio changing and maybe something on number of tweets to weight it.
sentiment = comb_data %>% 
  dplyr::filter(date > report_date - 60) %>%
  dplyr::select(date, tidy_loc1, negative, positive) %>%
  dplyr::group_by(tidy_loc1) %>%
  dplyr::summarise(total_negative = sum(negative, na.rm = TRUE),
            total_positive = sum(positive, na.rm = TRUE)) %>%
  dplyr::mutate(ratio = total_positive / total_negative)
# If ratio is > 1 and more positive sentiment than negative -1 from score.
# If ratio is < 1 and more negative sentiment that positive +1 from score.
sentiment$score = ifelse(sentiment$ratio > 1, -1, 1)
sentiment$score[is.na(sentiment$score)] = 0
sentiment = sentiment[which(!is.na(sentiment$tidy_loc1)),]
sentiment = select(sentiment, tidy_loc1,  score)
names(sentiment) = c("group", "score")

# Combines risk score
risk_score = NULL
if (use_rt == TRUE){
  risk_score = rbind(risk_score, rt)
}
if (use_projections == TRUE){
  risk_score = rbind(risk_score, cases)
}
if (use_vaccine_coverage == TRUE){
  risk_score = rbind(risk_score, coverage)
}
if (use_sentiment == TRUE){
  risk_score = rbind(risk_score, sentiment)
}

risk_scores = risk_score %>% 
  dplyr::group_by(group) %>%
  dplyr::summarise(total_score = sum(score))

risk_scores$classify = ifelse(risk_scores$total_score < 1, "low", 
                              ifelse(risk_scores$total_score < 5, "medium", "high"))

print(risk_scores)

# Selects the different data sources the user wants to generate the score
risk_scores_json = toJSON(risk_scores)
write(risk_scores_json, "risk_score.json")

saveRDS(risk_scores, file = "risk_score.rds")

