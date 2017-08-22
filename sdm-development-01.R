# Try 01 at SDM for eButterfly / ACIC
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-08-21

rm(list = ls())

################################################################################
# See:
# http://www.molecularecologist.com/2013/04/species-distribution-models-in-r/
# SETUP
# Load dependancies
# Get observation data (lat / long)
# Get bioclim data
# Prep bioclim data (restrict to geographic range of interest)

# Load dependancies
library("raster")
library("dismo")
library("rJava") # Installed via sudo apt-get install r-cran-java
# library("maxnet")

# Observation data
# TODO: do we want to use a subset of these points?
observation.data <- read.delim(file = "data/joshua-tree-data.txt",
                               header = TRUE)

# Bioclim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5,
                        path = "data/")

# Restrict bioclim data 
# TODO: this should probably be dynamic, drawn from the actual extent of points 
# in observation data
data.extent <- extent(-119.25, -112.75, 33.25, 38.25)
bioclim.data <- crop(x = bioclim.data, y = data.extent)
writeRaster(x = bioclim.data, 
            filename = "data/cropped-bioclim-2.5.grd", 
            overwrite = TRUE)
bioclim.data <- brick(x = "data/cropped-bioclim-2.5.grd")

################################################################################
# ANALYSES
# Pull out bioclim values for observation data
# Determine training vs. testing data
# Run analysis on training data
# Run analysis on testing data

# Bioclim at observation points

prediction.data <- extract(x = bioclim.data, y = observation.data[, c("longitude", "latitude")])
prediction.data <- data.frame(latitude = observation.data$latitude,
                              longitude = observation.data$longitude,
                              prediction.data)

# Assign each observation to one of five groups for train/test
group <- kfold(x = prediction.data, k = 5)

# Use group 1 for testing
testing.group <- 1
training.data <- prediction.data[group != testing.group, c("longitude", "latitude")]
testing.data <- prediction.data[group == testing.group, c("longitude", "latitude")]

maxent.model <- maxent(x = bioclim.data, p = training.data)
# Line below doesn't work because we need to provide value for the 'a' argument
maxent.eval <- evaluate(p = testing.data, model = maxent.model, x = bioclim.data)