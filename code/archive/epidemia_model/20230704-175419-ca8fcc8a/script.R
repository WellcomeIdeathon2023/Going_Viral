# This task takes a long time to run on a laptop - if you would like to 
# investigate decrease iter on line 56 but the model will not converge

# Reads in the data file
dat = readRDS("combined_dat.rds")

# Make data set at the admin level with zeros for days with no cases reported
start_date = min(dat$date)
end_date = max(dat$date)
tmp_date = data.frame(date=as.Date(start_date:end_date, origin='1970-01-01'))

# Remove cases with NA as location
dat = dat[which(!is.na(dat$tidy_loc1)),]

# Make a wide data frame for cases for each region per day for easy cleaning
case_dat = dat %>% 
  select(-positive, -negative) %>% 
  spread(key = tidy_loc1, value = case_count) %>%
  full_join(tmp_date, by = "date") 
case_dat = case_dat[order(case_dat$date),]

# Make NAs zero
case_dat[is.na(case_dat)] = 0 

# Start date on 1st August 2020 as month before when data changes to be London
# to allow seeding
# End date 22nd December 2020 as that's when data zeros in London "2020-12-22"
case_dat = case_dat %>%
  filter(date > as.Date("2020-07-01") & date <= as.Date("2020-12-22")) %>%
  select(-"England", -"Northern Ireland", -"Scotland", -"Wales")

# Gather the data - filter to just London for prototype
case_dat = gather(case_dat, key = "region", value = "cases", -date) %>%
  filter(region == "London")

# This would need to change if have weeks over 1 year
case_dat$week <- week(case_dat$date)

# Transmission model -  currently weekly varying random walk.
# Would add in YouGov / mobility / environmental / other behavioral data 
# here to parameterise model following research from Christian Morgenstern's 
# PhD at Imperial
rt <- epirt(formula = R(region, date) ~ 1 + rw(week, prior_scale = 0.01),
            prior_intercept = normal(log(2), 0.2), link = 'log')

# Observation model
# Assumes likely to test equally across 4 days after being infected
obs <- epiobs(formula = cases ~ 1, link = "identity",
              i2o = rep(.25,4))

# Infections model
# Should add in population weighting 
inf <- epiinf(gen = EuropeCovid$si, seed_days = 6)

args <- list(rt = rt, inf = inf, obs = obs, data = case_dat, seed = 12345,
             refresh = 0, iter = 1e2, control = list(max_treedepth = 12))

fm <- do.call(epim, args)

# Forecast assuming constant weekly effect
forecast_length = 7
new_dat = case_dat
additional_data = data.frame(date = as.Date(as.Date("2020-12-23"):(as.Date("2020-12-23")+forecast_length-1), origin='1970-01-01'),
                             region = rep("London", forecast_length),
                             cases = rep(0, forecast_length),
                             week = rep(max(case_dat$week), forecast_length))

new_dat = rbind(new_dat, additional_data)
ggsave("plot_rt.png", plot_rt(fm, newdata = new_dat))
ggsave("plot_cases.png", plot_obs(fm, type = "cases", newdata = new_dat))

save(case_dat, new_dat, fm, file = "model_run.RData")
