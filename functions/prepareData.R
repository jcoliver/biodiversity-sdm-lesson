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
  if (file.access(names = butterfly.data.file, mode = 4) != 0) {
    stop(paste0("You do not have sufficient access to read ", butterfly.data.file, "\n"))
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
  
  coordinate.data <- original.data[, c("longitude", "latitude")]
  colnames(coordinate.data) <- c("lon", "lat")
  
  # Remove duplicate rows
  duplicate.rows <- duplicated(x = coordinate.data)
  coordinate.data <- coordinate.data[!duplicate.rows, ]
  
  return(coordinate.data)
}

################################################################################
#' Finds minimum and maximum latitude and longitude
#' 
#' @param x a data.frame or list of data.frames
MinMaxCoordinates <- function(x) {
  if(class(x) == "data.frame") {
    x <- list(x)
  }
  
  max.lat <- -90
  min.lat <- 90
  max.lon <- -180
  min.lon <- 180
  
  for (i in 1:length(x)) {
    max.lat = ceiling(max(x[[i]]$lat, max.lat))
    min.lat = floor(min(x[[i]]$lat, min.lat))
    max.lon = ceiling(max(x[[i]]$lon, max.lon))
    min.lon = floor(min(x[[i]]$lon, min.lon))
  }

  min.max.coords <- c(min.lon, max.lon, min.lat, max.lat)
  names(min.max.coords) <- c("min.lon", "max.lon", "min.lat", "max.lat")
  return(min.max.coords)
}

################################################################################
#' Run species distribution modeling and return raster
#'
#' @param data data.frame with "lon" and "lat" values
SDMRaster <- function(data) {
  if (!require("raster")) {
    stop("SDMRaster requires raster package, but package is missing.")
  }

  # TODO: add additional checks for required packages
    
  # Determine minimum and maximum values of latitude and longitude
  min.max <- MinMaxCoordinates(x = data)
  geographic.extent <- extent(x = min.max)

  # Get the biolim data
  bioclim.data <- getData(name = "worldclim",
                          var = "bio",
                          res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                          path = "data/")
  bioclim.data <- crop(x = bioclim.data, y = geographic.extent)
  
  # Create pseudo-absence points (making them up, using 'background' approach)
  raster.files <- list.files(path = paste0(system.file(package = "dismo"), "/ex"),
                             pattern = "grd", full.names = TRUE)
  mask <- raster(raster.files[1])
  
  # Random points for background (same number as our observed points)
  set.seed(19470909)
  background.points <- randomPoints(mask = mask, n = nrow(data), ext = geographic.extent, extf = 1.25)
  colnames(background.points) <- c("lon", "lat")
  
  # Data for observation sites (presence and background)
  presence.values <- extract(x = bioclim.data, y = data)
  absence.values <- extract(x = bioclim.data, y = background.points)
  
  ################################################################################
  # ANALYSIS
  # Divide data into testing and training
  # Run SDM
  # Save graphics and raster files
  
  # Separate training & testing data
  group.presence <- kfold(data, 5)
  testing.group <- 1
  presence.train <- data[group.presence != testing.group, ]
  presence.test <- data[group.presence == testing.group, ]
  group.background <- kfold(background.points, 5)
  background.train <- background.points[group.background != testing.group, ]
  background.test <- background.points[group.background == testing.group, ]
  
  # Do species distribution modeling
  sdm.model <- bioclim(x = bioclim.data, p = presence.train)
  sdm.model.eval <- evaluate(p = presence.test, 
                             a = background.test, 
                             model = sdm.model, 
                             x = bioclim.data)
  sdm.model.threshold <- threshold(x = sdm.model.eval, 
                                   stat = "spec_sens")
  predict.presence <- predict(x = bioclim.data, 
                              object = sdm.model, 
                              ext = geographic.extent, 
                              progress = "")
  return(predict.presence > sdm.model.threshold)
}

#' Add two rasters into one
#' 
#' Returned raster has following values:
#'   NA: no pixels in either raster
#'   1: pixels >= 1 in raster1 and <= 0 in raster2
#'   2: pixels >= 1 in raster2 and <= 0 in raster1
#'   3: pixels >= 1 in raster1 and raster2
#' 
#' @param raster1
#' @param raster2
StackTwoRasters <- function(raster1, raster2) {
  if (!require("raster")) {
    stop("SDMRaster requires raster package, but package is missing.")
  }
  raster1[raster1 <= 0] <- NA
  raster2[raster2 <= 0] <- NA
  raster2[raster2 >= 1] <- 2
  
  # # Get extent
  # xmin <- min(extent(raster1)[1], extent(raster2)[1])
  # xmax <- max(extent(raster1)[2], extent(raster2)[2])
  # ymin <- min(extent(raster1)[3], extent(raster2)[3])
  # ymax <- max(extent(raster1)[4], extent(raster2)[4])
  # 
  # Create a mosaic by summing pixel values
  raster.mosaic <- mosaic(x = raster1, y = raster2, fun = sum)
  raster.mosaic[raster.mosaic <= 0] <- NA
  return(raster.mosaic)
}

