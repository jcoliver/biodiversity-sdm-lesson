# Lesson on biodiversity data and species distribution models

## v1.0.0

## Overview

Introductory lesson to generate range maps for butterfly-host plant interactions
and predict distributional shifts using publicly available biodiversity data and
data science tools. See [Clement *et al.* (2018) TIEE
**14**](http://tiee.esa.org/vol/v14/experiments/clement/abstract.html) for
additional information.

Detailed instructions can be found in
[docs/instructions.md](docs/instructions.md)

## Dependencies

Four additional R packages are required (these will be installed by running the
setup script, scripts/setup.R):

+ terra
+ geodata
+ predicts

## Structure

+ data
    + Adelpha_californica_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Adelpha californica*
        (Lepidoptera: Nymphalidae)
    + Aglais_io_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Aglais io* (Lepidoptera:
        Nymphalidae)
    + climate
        + wc2.1_2.5m: folder with climate data at 2.5 minute resolution from
            [WorldClim](http://www.worldclim.org). This and the containing
            "climate" folder are *not* under version control, but will be
            created when running the setup script (scripts/setup.R). The folder
            contains both contemporary climate data, as well as forecast climate
            data. The forecast data are for the year 2070, and based on the
            GFDL-ESM4 model under the SSP 3-7.0. For more information on the
            various climate models, see the [CMIP6
            site](https://www.carbonbrief.org/cmip6-the-next-generation-of-climate-models-explained/).
    + Danaus_gilippus_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Danaus gilippus*
        (Lepidoptera: Nymphalidae)
    + Fraxinus_velutina_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Fraxinus velutina*
        (Lamiales: Oleaceae)
    + gadm: folder to hold country border data; *not* under version control,
        but will be created upon first species distribution model analysis
    + Limenitis_archippus_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Limenitis archippus*
        (Lepidoptera: Nymphalidae)
    + Lycaena_xanthoides_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Lycaena xanthoides*
        (Lepidoptera: Lycaenidae)
    + Papilio_cresphontes_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Papilio cresphontes*
        (Lepidoptera: Papilionidae)
    + Papilio_multicaudata_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Papilio multicaudata*
        (Lepidoptera: Papilionidae)
    + Platanus_wrightii_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Platanus wrightii*
        (Proteales: Platanaceae)
    + Quercus_chrysolepis_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Quercus chrysolepus*
        (Fagales: Fagaceae)
    + Rumex_salicifolius_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Rumex salicifolius*
        (Caryophyllales: Polygonaceae)
    + Speyeria_mormo_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Speyeria mormo*
        (Lepidoptera: Nymphalidae)
    + Suggested_pairs.csv: suggested species pairs (butterfly + plant) for
        lessons
    + Urtica_dioica_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Urtica dioica* (Rosales:
        Urticaceae)
    + Zanthoxylum_americanum_data.csv: data harvested from
        [iNaturalist](http://www.inaturalist.org) for *Zanthoxylum americanum*
        (Sapindales: Rutaceae)
+ dev: developmental scripts for example images and code testing
+ docs: documentation for this code and lesson
    + instructions.md: instructions for installing software, downloading data,
        and running analyses
    + script-explanation.md: explanations of the four species distribution
        modeling scripts (all prefixed with "run-") in the scripts folder
    + troubleshooting.md: common challenges and possible solutions related to
        installing software and running analyses
+ functions
    + sdm-functions.R: functions used in species distribution models
+ img: images for [Instructions](docs/instructions.md)
+ output (contents are not under version control)
+ scripts (The [Script Explanation](docs/script-explanation.md) page provides
    more in-depth explanations of the species distribution modeling scripts)
    + examples: example scripts implementing the four "run-" scripts and two
        "plot-" scripts
    + get-observation-data.R: Harvest data from iNaturalist using their API
        based on a taxon ID; called from command line terminal
        + Usage: `Rscript --vanilla get-observation-data.R <taxon_id>`
        + Example: `Rscript --vanilla get-observation-data.R 60606`
    + plot-observations.R: Template to plot observations on a map
    + plot-six-panel.R: Template to generate species distribution models for a
        pair of species (generally, an insect and host plant) and create a six
        panel plot with the following panels:
        1.  observations of species one (e.g. an insect)
        2.  observations of species two (e.g. a plant)
        3.  contemporary species distribution model for species one
        4.  contemporary species distribution model for species two
        5.  contemporary species distribution models of species one and two,
            showing areas of difference and overlap
        6.  forecast species distribution models of species one and two, showing
            areas of difference and overlap
    + run-future-sdm-pairwise.R: Template to run species distribution model
        for an insect and its host plant species based on forecast climate model
    + run-future-sdm-single.R: Template to run species distribution model for
        a single species based on forecast climate model
    + run-sdm-pairwise.R: Template to run species distribution model for an
        insect and its host plant species based on current climate data
    + run-sdm-single.R: Template to run species distribution model for a
        single species based on current climate data
    + setup.R: Setup script to run at start of project, it will:
        + Install three additional R packages that are necessary for this
            lesson (terra, geodata, predicts)
        + Check to make sure the `data` folder was copied correctly during the
            cloning of the GitHub repository
        + Download contemporary and forecast climate data from the [WorldClim
            website](http://www.worldclim.org)
        + If it does not successfully complete all these tasks, please
            reference the [Troubleshooting](docs/troubleshooting.md) page.

*Side note*: This project was originally forked from
<https://github.com/jcoliver/ebutterfly-sdm.git>.

## Resources

### Species distribution models in R

+ _The_ [guide for SDMs in R](https://rspatial.org/sdm/)
+ Vignettes for the three R packages that this lesson heavily relies on:
  + [terra](https://cran.r-project.org/web/packages/terra/terra.pdf)
  + [geodata](https://cran.r-project.org/web/packages/geodata/geodata.pdf)
  + [predicts](https://cran.r-project.org/web/packages/predicts/predicts.pdf)
+ [A single-species focused
    lesson](https://jcoliver.github.io/learn-r/011-species-distribution-models.html)
+ [Fast and flexible Bayesian species distribution modelling using Gaussian
    processes](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12523/pdf)
+ [Species distribution models in
    R](http://www.molecularecologist.com/2013/04/species-distribution-models-in-r/)
+ [Run a range of species distribution
    models](https://rdrr.io/cran/biomod2/man/BIOMOD_Modeling.html)
+ [SDM polygons on a Google map](https://rdrr.io/rforge/dismo/man/gmap.html)
+ [R package 'maxnet' for functionality of Java maxent
    package](https://cran.r-project.org/web/packages/maxnet/maxnet.pdf)

### Climate forecast models

+ [McSweeney et al.
    2015](https://link.springer.com/article/10.1007/s00382-014-2418-8).

### iNaturalist

+ [API documentation](https://www.inaturalist.org/pages/api+reference)
