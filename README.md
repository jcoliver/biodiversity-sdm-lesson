# Lesson on biodiversity data and species distribution models
## v0.9.1

## Overview
Introductory lesson to generate range maps for butterfly-host plant interactions and predict distributional shifts using publicly available biodiversity data and data science tools.

Detailed instructions can be found in [instructions.md](instructions.md)

Originally forked from [https://github.com/jcoliver/ebutterfly-sdm.git](https://github.com/jcoliver/ebutterfly-sdm.git)

## Dependencies
Five additional R packages are required (these will be installed by running the the setup script, `scripts/setup.R`):

+ rgdal
+ raster
+ sp
+ dismo
+ maptools

## Structure
+ data
  + wc2-5: climate data at 2.5 minute resolution from [WorldClim](http://www.worldclim.org) (_note_: this folder is not under version control, but will be created by running the setup script (`scripts/setup.R`))
  + cmip5: forcast climate data at 2.5 minute resolution from [WorldClim](http://www.worldclim.org) (_note_: this folder is not under version control, but will be created by running the setup script (`scripts/setup.R`))
  + Lycaena_xanthoides_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Lycaena xanthoides_ (Lepidoptera: Lycaenidae)
  + Rumex_salicifolius_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Rumex salicifolius_ (Polygonaceae)
+ functions
  + prepareData.R: functions used in species distribution models
+ output (contents are not under version control)
+ scripts
  + examples: example scripts implementing the four `run-*` scripts
  + get-observation-data.R: Harvest data from iNaturalist using their API; 
  called from command line terminal
    + Usage: `Rscript --vanilla get-observation-data.R <taxon_id>`
    + Example: `Rscript --vanilla get-observation-data.R 60606`
  + run-future-sdm-pairwise.R: Run species distirbution model for an insect and its host plant species based on forecast climate model
  + run-future-sdm-single.R: Run species distirbution model for a single species based on forecast climate model
  + run-sdm-pairwise.R: Run species distirbution model for an insect and its host plant species based on current climate data
  + run-sdm-single.R: Run species distirbution model for a single species based on current climate data
  + setup.R: Setup script to run at start of project; installs dependencies and downloads climate data.

## Resources
### Species distribution models in R
+ [Vignette for `dismo` package](https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf)
+ [Fast and flexible Bayesian species distribution modelling using Gaussian processes](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12523/pdf)
+ [Species distribution models in R](http://www.molecularecologist.com/2013/04/species-distribution-models-in-r/)
+ [Run a range of species distribution models](https://rdrr.io/cran/biomod2/man/BIOMOD_Modeling.html)
+ [SDM polygons on a Google map](https://rdrr.io/rforge/dismo/man/gmap.html)
+ [R package 'maxnet' for functionality of Java maxent package](https://cran.r-project.org/web/packages/maxnet/maxnet.pdf)

### iNaturalist
+ [API documentation](https://www.inaturalist.org/pages/api+reference)