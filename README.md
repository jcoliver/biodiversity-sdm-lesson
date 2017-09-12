# README for species distribution modeling

## Overview
Code and sample data for running species distribution models from data 
harvested from [iNaturalist](http://www.inaturalist.org). Future implementations 
would also use data from the [eButterfly](http://www.e-butterfly.org) project.

################################################################################
## Structure
+ data
  + inaturalist: data harvested from [iNaturalist](http://www.inaturalist.org)
  + wc2-5: climate data at 2.5 minute resolution from [WorldClim](http://www.worldclim.org)
+ output (not included in repository, but this structure is assumed on local)
  + images
  + rasters
+ scripts
  + get-observation-data.R: Harvest data from iNaturalist using their API; 
  called from command line terminal
    + Usage: `Rscript --vanilla get-observation-data.R <taxon_id>`
  + run-sdm.R: Run species distribution model and create map and raster output; 
  called from command line terminal
    + Usage: `Rscript --vanilla run-sdm.R <path/to/data> <output-file-prefix>`
  + sdm-for-ACIC-lecture.R: Script to create map graphic used in ACIC lecture
  + sdm-iNat-melinus.R: Pilot species distribution modeling for _Strymon melinus_
  + sdm-iNat-xanthoides.R: Pilot species distribution modeling for _Lycaena xanthoides_

## General initial approach:

1. Retrieve historical climate data [http://www.worldclim.org](http://www.worldclim.org)
2. Get a list of all species in databases (eButterfly & iNaturalist)
3. Get lat/long data for one species from databases
4. Extract data for one month
5. Perform quality check (minimum # observations, appropriate latitude & longitude format)
6. Run SDM
7. Create graphic with standardized name for use on [eButterfly](http://www.e-butterfly.org)

Repeat steps 4-7 for remaining months  
Repeat steps 3-7 for remaining species

## Resources
### Species distribution models in R
+ [Vignette for `dismo` package](https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf)
+ [Fast and flexible Bayesian species distribution modelling using Gaussian processes](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12523/pdf)
+ [Species distribution models in R](http://www.molecularecologist.com/2013/04/species-distribution-models-in-r/)
+ [Run a range of species distribution models](https://rdrr.io/cran/biomod2/man/BIOMOD_Modeling.html)
+ [SDM polygons on a Google map](https://rdrr.io/rforge/dismo/man/gmap.html)
+ [R package 'maxnet' for functionality of Java maxent package](https://cran.r-project.org/web/packages/maxnet/maxnet.pdf)

### Tests of spatial overlap
+ [http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0056568](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0056568)
+ [http://onlinelibrary.wiley.com/doi/10.1111/geb.12455/pdf](http://onlinelibrary.wiley.com/doi/10.1111/geb.12455/pdf)