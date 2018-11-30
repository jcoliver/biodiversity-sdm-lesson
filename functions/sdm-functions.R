# Data preparation function for running sdm on iNaturalist data
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2017-10-31

################################################################################
#' Read in data from files
#' 
#' Makes sure files exist and are readable, then reads them into 
#' data frame. Checks for columns "latitude" and "longitude" and 
#' renames them "lat" and "lon", respectively. Removes duplicate 
#' rows.
#' 
#' @param file character vector of length one with file name
#' @param sep separator character, defaults to ","
PrepareData <- function(file, sep = ",") {
  # Make sure the input files exist
  if (!file.exists(file)) {
    stop(paste0("Cannot find input data file ", infile, ", file does not exist.\n"))
  }
  
  # Make sure the input files are readable
  if (file.access(names = file, mode = 4) != 0) {
    stop(paste0("You do not have sufficient access to read ", file, "\n"))
  }

  # Read data into data.frame
  original.data <- read.csv(file = file,
                            stringsAsFactors = FALSE,
                            sep = sep)

  # Make sure coordinate columns are in data
  if (!(any(colnames(original.data) == "longitude") 
        && any(colnames(original.data) == "latitude"))) {
    stop(paste0("Missing required column(s) in ", file, "; input file must have 'latitude' and 'longitude' columns.\n"))
  }
  
  # Extract only those columns of interest and rename them for use with 
  # dismo package tools
  coordinate.data <- original.data[, c("longitude", "latitude")]
  colnames(coordinate.data) <- c("lon", "lat")
  
  # Remove duplicate rows
  duplicate.rows <- duplicated(x = coordinate.data)
  coordinate.data <- coordinate.data[!duplicate.rows, ]
  coordinate.data <- na.omit(coordinate.data)

  return(coordinate.data)
}

################################################################################
#' Finds minimum and maximum latitude and longitude
#' 
#' @param x a data.frame or list of data.frames
MinMaxCoordinates <- function(x, padding = 0.1) {
  # If passed a single data.frame, wrap in a list
  if(class(x) == "data.frame") {
    x <- list(x)
  }
  
  # Establish starting min/max values
  max.lat <- -90
  min.lat <- 90
  max.lon <- -180
  min.lon <- 180
  
  # Iterate over all elements of list x and find min/max values
  for (i in 1:length(x)) {
    max.lat <- ceiling(max(x[[i]]$lat, max.lat))
    min.lat <- floor(min(x[[i]]$lat, min.lat))
    max.lon <- ceiling(max(x[[i]]$lon, max.lon))
    min.lon <- floor(min(x[[i]]$lon, min.lon))
  }

  if (padding > 0) {
    # Pad the values a bit so we don't end up with straight line distribution edges
    lon.pad <- padding * (max.lon - min.lon)
    lat.pad <- padding * (max.lat - min.lat)
    max.lat <- max.lat + lat.pad
    min.lat <- min.lat - lat.pad
    max.lon <- max.lon + lon.pad
    min.lon <- min.lon - lon.pad
  }
  
  # Format results and return
  min.max.coords <- c(min.lon, max.lon, min.lat, max.lat)
  names(min.max.coords) <- c("min.lon", "max.lon", "min.lat", "max.lat")
  return(min.max.coords)
}

################################################################################
#' Run species distribution modeling and return raster of predicted presence
#'
#' @param data data.frame with "lon" and "lat" values
#' @param padding numeric with percent to expand geographic extent to avoid 
#' artificial straight-line distribution borders
SDMRaster <- function(data, padding = 0.1) {
  # Determine minimum and maximum values of latitude and longitude
  min.max <- MinMaxCoordinates(x = data, padding = padding)
  geographic.extent <- extent(x = min.max)
  
  # Run the analysis and extract model & threshold
  sdm.bioclim <- SDMBioclim(data = data)
  sdm.model <- sdm.bioclim$sdm
  sdm.model.threshold <- sdm.bioclim$sdm.threshold
  
  # Get the biolim data for making predictions from model
  bioclim.data <- getData(name = "worldclim",
                          var = "bio",
                          res = 2.5,
                          path = "data/")
  bioclim.data <- crop(x = bioclim.data, y = geographic.extent)
  
  # Predict presence probability from model and bioclim data
  predict.presence <- predict(x = bioclim.data, 
                              object = sdm.model, 
                              ext = geographic.extent, 
                              progress = "")
  
  # Return raster with values indicating whether probability of 
  # presence was >= threshold (1) or < threshold (0)
  return(predict.presence > sdm.model.threshold)
}

################################################################################
#' Combine two presence/absence rasters into a single composite raster
#' 
#' @param raster1
#' @param raster2
#' @return raster::RasterLayer with the following values:
#'   * NA: no pixels in either raster
#'   * 1: pixels >= 1 in raster1 and <= 0 in raster2
#'   * 2: pixels >= 1 in raster2 and <= 0 in raster1
#'   * 3: pixels >= 1 in raster1 and raster2
StackTwoRasters <- function(raster1, raster2) {
  if (!require("raster")) {
    stop("SDMRaster requires raster package, but package is missing.")
  }
  raster1[raster1 <= 0] <- NA
  raster2[raster2 <= 0] <- NA
  raster2[raster2 >= 1] <- 2
  
  # Create a mosaic by summing pixel values
  raster.mosaic <- mosaic(x = raster1, y = raster2, fun = sum)
  raster.mosaic[raster.mosaic <= 0] <- NA
  return(raster.mosaic)
}

################################################################################
#' Run species distribution modeling on forcast climate data and return raster 
#' of predicted presence
#' 
#' @param data data.frame with "lon" and "lat" values
SDMForecast <- function(data, padding = 0.1) {
  # Load dependancies
  if (!require("raster")) {
    stop("SDMForecast requires raster package, but package is missing.")
  }
  if (!require("sp")) {
    stop("SDMForecast requires sp package, but package is missing.")
  }

  # Determine minimum and maximum values of latitude and longitude
  min.max <- MinMaxCoordinates(x = data, padding = padding)
  geographic.extent <- extent(x = min.max)

  # Run the analysis and extract model & threshold
  sdm.bioclim <- SDMBioclim(data = data)
  sdm.model <- sdm.bioclim$sdm
  sdm.model.threshold <- sdm.bioclim$sdm.threshold

  # FORECAST
  # Get bioclim & forecast data
  # Precict based on sdm.model
  
  # Get the biolim data (for column names to use in forecast data)
  bioclim.data <- getData(name = "worldclim",
                          var = "bio",
                          res = 2.5,
                          path = "data/")
  bioclim.data <- crop(x = bioclim.data, y = geographic.extent)

  # Load forecast data
  forecast.data <- raster::stack(x = "data/cmip5/2_5m/forecast-raster.gri")
  forecast.data <- crop(x = forecast.data, y = geographic.extent)

  # Predict presence probability from model and bioclim data
  predict.presence <- predict(x = forecast.data, 
                              object = sdm.model, 
                              ext = geographic.extent, 
                              progress = "")
  
  # Return raster with values indicating whether probability of 
  # presence was >= threshold (1) or < threshold (0)
  return(predict.presence > sdm.model.threshold)
}

################################################################################
#' Run species distribution model and return model and threshold
#' 
#' @param data data.frame with "lon" and "lat" values
SDMBioclim <- function(data, padding = 0.1) {
  ########################################
  # SETUP
  # Load dependancies
  # Prepare data
  
  # Load dependancies
  if (!require("raster")) {
    stop("SDMRaster requires raster package, but package is missing.")
  }
  if (!require("dismo")) {
    stop("SDMRaster requires dismo package, but package is missing.")
  }
  
  # Prepare data
  # Determine minimum and maximum values of latitude and longitude
  min.max <- MinMaxCoordinates(x = data, padding = padding)
  geographic.extent <- extent(x = min.max)
  
  # Get the biolim data
  bioclim.data <- getData(name = "worldclim",
                          var = "bio",
                          res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                          path = "data/")
  bioclim.data <- crop(x = bioclim.data, y = geographic.extent)
  
  # Create pseudo-absence points (making them up, using 'background' approach)
  # raster.files <- list.files(path = paste0(system.file(package = "dismo"), "/ex"),
  #                            pattern = "grd", full.names = TRUE)
  # mask <- raster(raster.files[1])
  bil.files <- list.files(path = "data/wc2-5", 
                          pattern = "*.bil$", 
                          full.names = TRUE)
  mask <- raster(bil.files[1])
  
  # Random points for background (same number as our observed points)
  set.seed(19470909)
  background.extent <- extent(x = MinMaxCoordinates(x = data, padding = 0.0))
  # raster package will complain about not having coordinate reference system,
  # so we suppress that warning
  background.points <- suppressWarnings(randomPoints(mask = mask, 
                                                     n = nrow(data), 
                                                     ext = background.extent, 
                                                     extf = 1.25))
  colnames(background.points) <- c("lon", "lat")
  
  # Data for observation sites (presence and background)
  presence.values <- extract(x = bioclim.data, y = data)
  absence.values <- extract(x = bioclim.data, y = background.points)
  
  ########################################
  # ANALYSIS
  # Divide data into testing and training
  # Generate species distribution model
  
  # Divide data into testing and training
  group.presence <- kfold(data, 5)
  testing.group <- 1
  presence.train <- data[group.presence != testing.group, ]
  presence.test <- data[group.presence == testing.group, ]
  group.background <- kfold(background.points, 5)
  background.train <- background.points[group.background != testing.group, ]
  background.test <- background.points[group.background == testing.group, ]
  
  # Generate species distribution model
  sdm.model <- bioclim(x = bioclim.data, p = presence.train)
  # Evaluate performance so we can determine predicted presence 
  # threshold cutoff
  sdm.model.eval <- evaluate(p = presence.test, 
                             a = background.test, 
                             model = sdm.model, 
                             x = bioclim.data)
  sdm.model.threshold <- threshold(x = sdm.model.eval, 
                                   stat = "spec_sens")
  
  return(list(sdm = sdm.model, sdm.threshold = sdm.model.threshold))
}
