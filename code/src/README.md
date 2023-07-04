# orderly: src

To generate our prototype please follow these steps:

1) Load in the orderly package
```
library(orderly)
```

2) Download / create our incoming data sources.  This requires an api key for
the globaldothealth data set to be set as an environment variable `$API_KEY`.
```
orderly_run("incoming_globaldothealth")
orderly_run("incoming_vaxtweets")
orderly_run("incoming_interview")
```

3) Combine the case data, vax tweets and xxx into one dataset for future tasks.  
#TODO add in about archiving
```
orderly_run("collate_data", use_draft = TRUE)
```

4) Does one week forecasts in epidemia () using case data for the prototype.  This will be 
expanded in the full project building on work from a PhD student at DIDE, Imperial
who is looking at methodological changes to bringing in YouGov and other behavioural
data sets.
This step runs a Bayesian model so may be slow to run to convergence on your computer.
The number of iterations is set to 1e2 so the pipeline will run. The model will not have converged with this number of iterations. This needs to be increased to at least xxx
```
orderly_run("epidemia_model", use_draft = TRUE)
#orderly_run("epidemia_model", parameters = list(n_iter = 1000), use_draft = TRUE)
```