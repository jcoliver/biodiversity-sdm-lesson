# README for species distribution modeling

### General approach:

1. Retrieve historical climate data [http://www.worldclim.org](http://www.worldclim.org)
2. Get a list of all species in databases (eButterfly & iNaturalist)
3. Get lat/long data for one species from databases
4. Extract data for one month
5. Perform quality check (minimum # observations)
6. Run SDM
7. Create graphic with standardized name for use on eButterfly.org web resource

Repeat steps 4-7 for remaining months  
Repeat steps 3-7 for remaining species

### R resources for SDM
+ [Vignette for `dismo` package](https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf)
+ [Fast and flexible Bayesian species distribution modelling using Gaussian processes](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12523/pdf)
+ [Species distribution models in R](http://www.molecularecologist.com/2013/04/species-distribution-models-in-r/)
+ [Run a range of species distribution models](https://rdrr.io/cran/biomod2/man/BIOMOD_Modeling.html)
+ [SDM polygons on a Google map](https://rdrr.io/rforge/dismo/man/gmap.html)
+ [R package 'maxnet' for functionality of Java maxent package](https://cran.r-project.org/web/packages/maxnet/maxnet.pdf)