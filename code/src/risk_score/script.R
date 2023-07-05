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

# Consider case projections for the week
cases = plot_obs(fm, newdata = new_dat, type = "cases")$layers[[3]]$data %>% 
  filter(date > report_date) %>% 
  group_by(group) %>%
  summarise(daily_mean = mean(median))
# Weekly forecast score contribution. Plus one if mean increase is greater than 
# 100 (probably would want to be population weighted), minus one if 0 cases are 
# forecast.
cases$score = ifelse(cases$daily_mean > 100, 1, 
                     ifesle(cases$daily_mean == 0, -1, 0))
cases = cases %>% select(-daily_mean)


# Selects the different data sources the user wants to generate the score
saveRDS(1, file = "risk_score.rds")
