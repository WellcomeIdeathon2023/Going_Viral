# Reads in the data file
dat = readRDS("combined_dat.rds")

# Make data set at the admin level with zeros 
start_date = min(dat$date)
end_date = max(dat$date)
tmp_date = data.frame(date=as.Date(start_date:end_date, origin='1970-01-01'))

# Remove NAs
dat = dat[which(!is.na(dat$tidy_loc1)),]

# Make a wide data frame for cases for each region per day
case_dat = dat %>% 
  select(-positive, -negative) %>% 
  spread(key = tidy_loc1, value = case_count) %>%
  full_join(tmp_date, by = "date") 
case_dat = case_dat[order(case_dat$date),]

# Make NAs zero
case_dat[is.na(case_dat)] = 0 

# Start data on first September 2020 as when data changes to be London
case_dat = case_dat %>%
  filter(date > as.Date("2020-08-31") & date <= as.Date("2020-12-22")) %>%
  select(-"England", -"Northern Ireland", -"Scotland", -"Wales")




saveRDS(1, file = "model_run.rds")
