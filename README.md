# README

This is your private repository for working on the challenges in the Wellcome Data Science Ideathon.
This repository is maintained and monitored by Wellcome staff and will be made public after July 13 2023.
Feel free to create additional folders in this repository but please use the existing ones as follows:

* `data` - Any data that is loaded from your scripts (excluding data scraped/downloaded from the web) should be uploaded to this folder. Simulated data should be reproducible.
* `code` - All code used as part of your solution should be uploaded this folder and is expected to be reproducible.
* `results` - Final results, including presented slides and other content, should be uploaded to this folder.

# LICENCE

The code in this repository is licenced under a permissive [MIT licence](https://opensource.org/licenses/MIT). All other content is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). This means you may use any content in this repository as long as you credit the authors.

# Required packages
* orderly
* globaldothealth (devtools::install_github("globaldothealth/list/api/R"))
* dplyr
* tidytext
* wordcloud
* stopwords
* epidemia (devtools::install_github("ImperialCollegeLondon/epidemia"))
* lubridate
* tidyr

# Running the prototype

Our 'orderly' repository can be found in the code folder. This includes 2 main folders: src, where you will find our scripts; archive, where you will find our outputs from running the code. There are also guidelines on how to download the orderly R package and which order to run the reports in.  