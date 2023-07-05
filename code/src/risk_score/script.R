# Loads all the different data sources 
comb_data = readRDS("combined_dat.rds")
load("model_run.RData")

# Choose date to make prediction for
if (date == "NA"){
  # Set date to maximum data in data set if not given
  report_date = max(case_dat$date) 
} else (
  report_date = as.date(date, origin='1970-01-01')
)

# Select rt values for given date. 
rt = plot_rt(fm, newdata = new_dat)$data %>% 
  filter(date == report_date) %>%
  filter(tag != "60% CI") # Only consider 30 and 90% CIs for score metric
# Rt risk score contribution.  Plus one if lower 90% CI is above 1 and if lower
# 30% CI is above 1.(Basically +2 if 90% > 1 and +1 if only 30% > 1)
rt$score = ifelse(rt$lower > 1, 1, 0) 
rt = rt %>% group_by(group) %>%
  summarise(score = sum(score))

# Consider case projections for the next week
cases = plot_obs(fm, newdata = new_dat, type = "cases")$layers[[3]]$data %>% 
  filter(date > report_date) %>% 
  group_by(group) %>%
  summarise(daily_mean = mean(median))
# Weekly forecast score contribution. Plus one if mean increase is greater than 
# 100 (probably would want to be population weighted), minus one if 0 cases are 
# forecast.
cases$score = ifelse(cases$daily_mean > 100, 1, 
                     ifelse(cases$daily_mean == 0, -1, 0))
cases = cases %>% select(-daily_mean)

# Consider vaccine coverage on the date of report
coverage = comb_data %>% 
  select(date, tidy_loc1, coverage) %>%
  filter(date >= report_date)
# If coverage is less than 25% increase risk score by 2, if less than 50% increase
# by 1. If vaccination is 95% or more decrease risk score by 1.
coverage$score = ifelse(coverage$coverage < 0.25, 2, 
                        ifelse(coverage$coverage < 0.5, 1, 
                        ifelse(coverage$coverage >= 0.95, -1, 0)))
coverage = coverage %>% 
  ungroup() %>% 
  select(-coverage, -date)
names(coverage) = c("group", "score")

# Consider tweet sentiment
sentiment = comb_data %>% 
  filter(date > report_date - 7) %>%
  select(date, tidy_loc1, negative, positive) 

# Combines risk score
risk_score = NULL
if (use_rt == TRUE){
  risk_score = rbind(risk_score, rt)
}
if (use_projections == TRUE){
  risk_score = rbind(risk_score, cases)
}
if(use_vaccine_coverage == TRUE){
  risk_score = rbind(risk_score, coverage)
}
if(use_sentiment == TRUE){
  #risk_score = rbind(risk_score, sentiment)
}

risk_scores = risk_score %>% 
  group_by(group) %>%
  summarise(total_score = sum(score))

risk_scores$classify = ifelse(risk_scores$total_score < 1, "low", 
                              ifelse(risk_scores$total_score < 5, "medium", "high"))
  
# Selects the different data sources the user wants to generate the score
saveRDS(risk_scores, file = "risk_score.rds")
