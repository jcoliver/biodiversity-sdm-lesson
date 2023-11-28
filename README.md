# Lesson on biodiversity data and species distribution models
## v0.9.4

**NOTE**: This lesson relies on several R packages that were retired in late 
2023 (e.g. maptools, raster, sp). The lesson will need to be updated with the 
successor packages (e.g. terra, geodata, predicts). In the meantime, you can 
find a lesson using current R packages for making predictions on a single 
species at 
[https://jcoliver.github.io/learn-r/011-species-distribution-models.html](https://jcoliver.github.io/learn-r/011-species-distribution-models.html).

## Overview
Introductory lesson to generate range maps for butterfly-host plant interactions and predict distributional shifts using publicly available biodiversity data and data science tools. See [Clement _et al._ (2018) TIEE **14**](http://tiee.esa.org/vol/v14/experiments/clement/abstract.html) for additional information.

Detailed instructions can be found in [docs/instructions.md](docs/instructions.md)

Originally forked from [https://github.com/jcoliver/ebutterfly-sdm.git](https://github.com/jcoliver/ebutterfly-sdm.git)

## Dependencies
Four additional R packages are required (these will be installed by running the the setup script, `scripts/setup.R`):

+ raster
+ sp
+ dismo
+ maptools

## Structure
+ data
  + wc2-5: climate data at 2.5 minute resolution from [WorldClim](http://www.worldclim.org) (_note_: this folder is not under version control, but will be created by running the setup script (`scripts/setup.R`))
  + cmip5: forcast climate data at 2.5 minute resolution from [WorldClim](http://www.worldclim.org). These data were originally downloaded from the WorldClim website, but stored in the `.RData` format for ease of use. The data are for the year 2070, based on the GFDL-ESM2G model with an RCP of 4.5 CO<sub>2</sub>. For an examination of different forecast models, see [McSweeney et al. 2015](https://link.springer.com/article/10.1007/s00382-014-2418-8).
  + Adelpha_californica_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Adelpha californica_ (Lepidoptera: Nymphalidae)
  + Danaus_gilippus_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Danaus gilippus_ (Lepidoptera: Nymphalidae)
  + Fraxinus_velutina_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Fraxinus velutina_ (Lamiales: Oleaceae)
  + Limenitis_archippus_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Limenitis archippus_ (Lepidoptera: Nymphalidae)
  + Lycaena_xanthoides_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Lycaena xanthoides_ (Lepidoptera: Lycaenidae)
  + Papilio_cresphontes_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Papilio cresphontes_ (Lepidoptera: Papilionidae)
  + Papilio_multicaudata_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Papilio multicaudata_ (Lepidoptera: Papilionidae)
  + Platanus_wrightii_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Platanus wrightii_ (Proteales: Platanaceae)
  + Quercus_chrysolepis_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Quercus chrysolepus_ (Fagales: Fagaceae)
  + Rumex_salicifolius_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Rumex salicifolius_ (Caryophyllales: Polygonaceae)
  + Speyeria_mormo_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Speyeria mormo_ (Lepidoptera: Nymphalidae)
  + Suggested_pairs.csv: suggested species pairs (butterfly + plant) for lessons
  + Urtica_dioica_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Urtica dioica_ (Rosales: Urticaceae)
  + Zanthoxylum_americanum_data.csv: data harvested from [iNaturalist](http://www.inaturalist.org) for _Zanthoxylum americanum_ (Sapindales: Rutaceae)
+ dev: developmental scripts for example images and code testing
+ docs: documentation for this code and lesson
    + instructions.md: instructions for installing software, downloading data, and running analyses
    + script-explanation.md: explanations of the four species distribution modeling scripts (all prefixed with "`run-*`") in the `scripts` folder
    + troubleshooting.md: common challenges and possible solutions related to installing software and running analyses
+ functions
  + sdm-functions.R: functions used in species distribution models
+ img: images for [Instructions](docs/instructions.md)
+ output (contents are not under version control)
+ scripts (The [Script Explanation](docs/script-explanation.md) page provides more in-depth explanations of the species distribution modeling scripts)
  + examples: example scripts implementing the four `run-*` scripts and two `plot-*` scripts
  + get-observation-data.R: Harvest data from iNaturalist using their API based on a taxon ID; 
  called from command line terminal
    + Usage: `Rscript --vanilla get-observation-data.R <taxon_id>`
    + Example: `Rscript --vanilla get-observation-data.R 60606`
  + plot-observations.R: Template to plot observations on a map
  + plot-six-panel.R: Template to generate species distribution models for a pair of species (generally, an insect and host plant) and create a six panel plot with the following panels: (1) Observations of species one (e.g. an insect), (2) observations of species two (e.g. a plant), (3) contemporary species distribution model for species one, (4) contemporary species distribution model for species two, (5) contemporary species distribution models of species one and two, showing areas of difference and overlap, (6) forecast species distribution models of species one and two, showing areas of difference and overlap
  + run-future-sdm-pairwise.R: Template to run species distribution model for an insect and its host plant species based on forecast climate model
  + run-future-sdm-single.R: Template to run species distribution model for a single species based on forecast climate model
  + run-sdm-pairwise.R: Template to run species distribution model for an insect and its host plant species based on current climate data
  + run-sdm-single.R: Template to run species distribution model for a single species based on current climate data
  + setup.R: Setup script to run at start of project, it will:
    + Install four additional R packages that are necessary for this lesson (raster, sp, dismo, maptools)
    + Check to make sure the `data` folder was copied correctly during the cloning of the GitHub repository
    + Download climate data from the [WorldClim website](http://www.worldclim.org)
  If it does not successfully complete all these tasks, please reference the [Troubleshooting](docs/troubleshooting.md) page.

## Resources
### Species distribution models in R
+ [Vignette for `dismo` package](https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf)
+ [Fast and flexible Bayesian species distribution modelling using Gaussian processes](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12523/pdf)
+ [Species distribution models in R](http://www.molecularecologist.com/2013/04/species-distribution-models-in-r/)
+ [Run a range of species distribution models](https://rdrr.io/cran/biomod2/man/BIOMOD_Modeling.html)
+ [SDM polygons on a Google map](https://rdrr.io/rforge/dismo/man/gmap.html)
+ [R package 'maxnet' for functionality of Java maxent package](https://cran.r-project.org/web/packages/maxnet/maxnet.pdf)

### Climate forecast models
+ [McSweeney et al. 2015](https://link.springer.com/article/10.1007/s00382-014-2418-8).

### iNaturalist
+ [API documentation](https://www.inaturalist.org/pages/api+reference)