# orderly

This is an [`orderly`](https://github.com/vimc/orderly) project. The directories are:

* `src`: create new reports here
* `archive`: versioed results of running your report
* `data`: copies of data used in the reports

(you can delete or edit this file safely)

## Running reports

### Requirements

1. R
1. The `orderly` R package:
    ```
   install.packages("orderly")
   ```

1. `orderly` will prompt you to install missing packages as reports are run,
   but a couple are missing from cran so should first be installed manually:
    ```
    devtools::install_github("globaldothealth/list/api/R")
    devtools::install_github("ImperialCollegeLondon/epidemia")
    ```

1. To run the `incoming_globaldothealth` report you will need an environment variable called API_KEY
   that contains your api key. Instructions for generating a key
   here: https://github.com/globaldothealth/list/tree/main/api#get-your-api-key

### Report pipeline

Reports can be run and committed to the archive with `orderly::orderly_run` and `orderly::orderly_commit`.
See https://www.vaccineimpact.org/orderly/reference/index.html#basic-use

1. The reports `incoming_globaldothealth`, `incoming_vaxtweets`, `incoming_interviews`, and `incoming_vaccinationcoverage` download/generate/process our incoming data sources.  This requires an api key for
   the globaldothealth data set to be set as an environment variable `$API_KEY`.

   ```
   Sys.setenv(API_KEY = "xxxx"")
   orderly::orderly_run("incoming_globaldothealth")
   orderly::orderly_run("incoming_vaxtweets")
   orderly::orderly_run("incoming_interview")
   orderly::orderly_run("incoming_vaccinationcoverage")
   ```

1. The `collate_data` report combines the case data, vax tweets interviews and vaccination coverage into one data set for future tasks.
   ```
   orderly::orderly_run("collate_data")
   ```
   
1. The `epidemia_model` reports implements one week forecasts in the epidemia package (https://imperialcollegelondon.github.io/epidemia/index.html) using case data only for the prototype.  This will be expanded in the full project building on work from a PhD student at DIDE, Imperial who is looking at methodological changes to bringing in YouGov and other behavioural data sets.
   This step runs a Bayesian model so may be slow to run to convergence on your computer.The default number of iterations is set to 1e2 so the pipeline will run on a laptop. The model will not have converged with this number of iterations. This needs to be increased to at least 10000.
   ```
   orderly::orderly_run("epidemia_model")
   #orderly::orderly_run("epidemia_model", parameters = list(n_iter = 10000))
   ```
   
1. The `risk_score` report calculates aggregate risk scores
   ```
   orderly::orderly_run("risk_score")
   ```

## Running OrderlyWeb (the data pipeline web interface)

Make sure your working directory is the `code` subdirectory.
To run OW first make sure you have initialised the `orderly` database:

    orderly::orderly_rebuild(".")

Then from a bash terminal:

   ```
   ./run.sh
   ```
