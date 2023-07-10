# orderly

This is an [`orderly`](https://github.com/vimc/orderly) project.  The directories are:

* `src`: create new reports here
* `archive`: versioed results of running your report
* `data`: copies of data used in the reports

(you can delete or edit this file safely)

## Running reports

1. Install `orderly`:
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
that contains your api key. Instructions for generating a key here: https://github.com/globaldothealth/list/tree/main/api#get-your-api-key

1. Run and commit reports with `orderly::orderly_run` and `orderly::orderly_commit`. See https://www.vaccineimpact.org/orderly/reference/index.html#basic-use

## Running OrderlyWeb

To run OW first make sure you have initialised the `orderly` database:

    orderly::orderly_rebuild(".")
    
Then from a bash terminal:
```
docker pull vimc/orderly-web-standalone:master
docker run --rm -p 8888:8888 -v $PWD:/orderly -v $PWD/dash/config:/etc/orderly/web -v $PWD/dashlogo:/static/public/img/logo vimc/orderly-web-standalone:master
```
