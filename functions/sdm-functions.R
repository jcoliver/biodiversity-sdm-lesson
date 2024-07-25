# Data preparation function for running sdm on iNaturalist data
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2017-10-31

################################################################################
#' Read in data from files
#' 
#' @details Makes sure files exist and are readable, then reads them into data 
#' frame. Checks for columns "latitude" and "longitude" and renames them "lat" 
#' and "lon", respectively. Removes duplicate rows.
#' 
#' @param file character vector of length one with file name
#' @param sep separator character, defaults to ","
#' 
#' @return a two-column data frame with lat and lon columns
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
  original_data <- read.csv(file = file,
                            sep = sep)

  # Make sure coordinate columns are in data
  if (!(any(colnames(original_data) == "longitude") 
        && any(colnames(original_data) == "latitude"))) {
    stop(paste0("Missing required column(s) in ", file, 
                "; input file must have 'latitude' and 'longitude' columns.\n"))
  }
  
  # Extract only those columns of interest and rename them for consistent use
  coordinate_data <- original_data[, c("longitude", "latitude")]
  colnames(coordinate_data) <- c("lon", "lat")
  
  # Remove duplicate rows
  duplicate_rows <- duplicated(x = coordinate_data)
  coordinate_data <- coordinate_data[!duplicate_rows, ]
  coordinate_data <- na.omit(coordinate_data)

  return(coordinate_data)
}

################################################################################
#' Finds minimum and maximum latitude and longitude
#' 
#' @param x a data.frame or list of data.frames
#' @param padding numeric increase in coordinates to add to bounds; 0.1 
#' (default) adds 10% to each of the four sides
MinMaxCoordinates <- function(x, padding = 0.1) {
  # If passed a single data.frame, wrap in a list
  if(class(x) == "data.frame") {
    x <- list(x)
  }
  
  # Establish starting min/max values
  max_lat <- -90
  min_lat <- 90
  max_lon <- -180
  min_lon <- 180
  
  # Iterate over all elements of list x and find min/max values
  for (i in 1:length(x)) {
    max_lat <- ceiling(max(x[[i]]$lat, max_lat))
    min_lat <- floor(min(x[[i]]$lat, min_lat))
    max_lon <- ceiling(max(x[[i]]$lon, max_lon))
    min_lon <- floor(min(x[[i]]$lon, min_lon))
  }

  if (padding > 0) {
    # Pad the values a bit so we don't end up with straight line distribution edges
    lon_pad <- padding * (max_lon - min_lon)
    lat_pad <- padding * (max_lat - min_lat)
    max_lat <- max_lat + lat_pad
    min_lat <- min_lat - lat_pad
    max_lon <- max_lon + lon_pad
    min_lon <- min_lon - lon_pad
  }
  
  # Format results and return
  min_max_coords <- c(min_lon, max_lon, min_lat, max_lat)
  names(min_max_coords) <- c("min_lon", "max_lon", "min_lat", "max_lat")
  return(min_max_coords)
}

################################################################################
#' Run species distribution modeling and return raster of predicted presence
#'
#' @param data data.frame with "lon" and "lat" values
#' @param padding numeric increase in coordinates to add to bounds; 0.1 
#' (default) adds 10% to each of the four sides; used to help avoid artificial 
#' straight-line distribution borders
#' 
#' @return SpatRaster with binary predicted absence/presence (0/1) values
SDMRaster <- function(data, padding = 0.1) {
  if (!require("terra")) {
    stop("SDMRaster requires the terra package, but package is missing.")
  }
  if (!require("geodata")) {
    stop("SDMRaster requires the geodata package, but package is missing.")
  }
  # Determine minimum and maximum values of latitude and longitude
  min_max <- MinMaxCoordinates(x = data, padding = padding)
  geographic_extent <- terra::ext(x = min_max)
  
  # Run the analysis and extract model & threshold
  sdm_bioclim <- SDMBioclim(data = data)
  sdm_model <- sdm_bioclim$sdm
  sdm_model_threshold <- sdm_bioclim$sdm_threshold
  
  # Get the biolim data for making predictions from model
  bioclim_data <- geodata::worldclim_global(var = "bio",
                                            res = 2.5, 
                                            path = "data")

  bioclim_data <- terra::crop(x = bioclim_data, y = geographic_extent)
  
  # Predict presence probability from model and bioclim data
  predict_presence <- predict(sdm_model, 
                              bioclim_data)
  
  # Return SpatRaster with values indicating whether probability of 
  # presence was >= threshold (1) or < threshold (0)
  return(predict_presence > sdm_model_threshold)
}

################################################################################
#' Combine two presence/absence SpatRaster into a single composite SpatRaster
#' 
#' @param raster1 SpatRaster
#' @param raster2 SpatRaster
#' @return SpatRaster with the following values:
#'   * NA: no pixels in either raster
#'   * 1: pixels >= 1 in raster1 and <= 0 in raster2
#'   * 2: pixels >= 1 in raster2 and <= 0 in raster1
#'   * 3: pixels >= 1 in raster1 and raster2
StackTwoRasters <- function(raster1, raster2) {
  if (!require("terra")) {
    stop("StackTwoRasters requires the terra package, but package is missing.")
  }
  raster1[raster1 <= 0] <- NA
  raster2[raster2 <= 0] <- NA
  raster2[raster2 >= 1] <- 2
  
  # Create a mosaic by summing pixel values
  raster_mosaic <- terra::mosaic(x = raster1, y = raster2, fun = "sum")
  raster_mosaic[raster_mosaic <= 0] <- NA
  return(raster_mosaic)
}

################################################################################
#' Run species distribution modeling on forcast climate data and return raster 
#' of predicted presence
#' 
#' @param data data.frame with "lon" and "lat" values
#' @param padding numeric increase in coordinates to add to bounds; 0.1 
#' (default) adds 10% to each of the four sides; used to help avoid artificial 
#' straight-line distribution borders
SDMForecast <- function(data, padding = 0.1) {
  # Load dependancies
  if (!require("terra")) {
    stop("SDMForecast requires the terra package, but package is missing.")
  }
  if (!require("geodata")) {
    stop("SDMForecast requires the geodata package, but package is missing.")
  }
  
  # Determine minimum and maximum values of latitude and longitude
  min_max <- MinMaxCoordinates(x = data, padding = padding)
  geographic_extent <- terra::ext(x = min_max)

  # Run the analysis and extract model & threshold
  sdm_bioclim <- SDMBioclim(data = data)
  sdm_model <- sdm_bioclim$sdm
  sdm_model_threshold <- sdm_bioclim$sdm_threshold

  # FORECAST
  # Get forecast data
  # Precict based on sdm_model
  
  # Get the biolim data for updating names in data to match those in model
  bioclim_data <- geodata::worldclim_global(var = "bio",
                                            res = 2.5,
                                            path = "data")

  # Get forecast data
  forecast_data <- geodata::cmip6_world(model = "GFDL-ESM4", 
                                        ssp = "370", 
                                        time = "2061-2080", 
                                        var = "bioc", 
                                        res = 2.5, 
                                        path = "data")

  # Update layer names to match bioclim_data layer names
  names(forecast_data) <- names(bioclim_data)
  
  # forecast.data <- crop(x = forecast.data, y = geographic_extent)
  forecast_data <- terra::crop(x = forecast_data, y = geographic_extent)

  # Predict presence probability from model and bioclim data
  predict_presence <- predict(sdm_model, 
                              forecast_data)
  
  # Return raster with values indicating whether probability of 
  # presence was >= threshold (1) or < threshold (0)
  return(predict_presence > sdm_model_threshold)
}

################################################################################
#' Run species distribution model and return model and threshold
#' 
#' @param data data.frame with "lon" and "lat" values
#' @param padding numeric increase in coordinates to add to bounds; 0.1 
#' (default) adds 10% to each of the four sides; used to help avoid artificial 
#' straight-line distribution borders
#' 
#' @return list with two elements:
#' \describe{
#'   \item{sdm}{Climate envelope model, commonly referred to as the "bioclim" 
#'   model; the output of a call to `predicts::envelope()`}
#'   \item{sdm_threshold}{Threshold for determining presence / absence, in this 
#'   case "the threshold at which the sum of the sensitivity (true positive 
#'   rate) and specificity (true negative rate) is highest" ("max_spec_sens")}
#' } #' 
SDMBioclim <- function(data, padding = 0.1) {
  ########################################
  # SETUP
  # Load dependancies
  # Prepare data
  
  # Load dependancies
  if (!require("terra")) {
    stop("SDMBioclim requires terra package, but package is missing.")
  }
  if (!require("geodata")) {
    stop("SDMBioclim requires geodata package, but package is missing.")
  }
  if (!require("predicts")) {
    stop("SDMBioclim requires predicts package, but package is missing.")
  }
  
  # Prepare data
  # Determine minimum and maximum values of latitude and longitude
  min_max <- MinMaxCoordinates(x = data, padding = padding)
  geographic_extent <- terra::ext(x = min_max)

  # Get the biolim data
  bioclim_data <- geodata::worldclim_global(var = "bio",
                                            res = 2.5,
                                            path = "data")
  
  bioclim_data <- terra::crop(x = bioclim_data, y = geographic_extent)
  
  # Create pseudo-absence points (making them up, using 'background' approach)
  tif_files <- list.files(path = "data/wc2.1_2.5m", 
                          pattern = "*.tif$", 
                          full.names = TRUE)
  mask <- terra::rast(tif_files[1])
  
  # Random points for background (same number as our observed points)
  set.seed(19470909)
  background_extent <- terra::ext(x = MinMaxCoordinates(x = data, 
                                                        padding = 0.0))
  # Using the "mask" so points are sampled at same resolution of climate data
  # We set xy = TRUE so the sampling returns the sampled coordinates (lat/lon)
  #    and values = FALSE, because we do not need the climate values of mask 
  #    returned, just the coordinates.
  background_points <- terra::spatSample(x = mask,
                                         size = nrow(data),
                                         ext = background_extent,
                                         exp = 1.25,
                                         xy = TRUE,
                                         values = FALSE)

  colnames(background_points) <- c("lon", "lat")
  
  # Data for observation sites (presence and background)
  presence_values <- terra::extract(x = bioclim_data, 
                                    y = data, 
                                    ID = FALSE)
  absence_values <- terra::extract(x = bioclim_data, 
                                   y = background_points)
  
  ########################################
  # ANALYSIS
  # Divide data into testing and training
  # Generate species distribution model
  
  # Divide data into testing and training
  group_presence <- predicts::folds(x = data, k = 5)
  testing_group <- 1
  presence_train <- presence_values[group_presence != testing_group, ]
  presence_test <- presence_values[group_presence == testing_group, ]
  group_background <- predicts::folds(x = background_points, k = 5)

  # Generate species distribution model
  sdm_model <- predicts::envelope(x = presence_train)
  
  # Evaluate performance so we can determine predicted presence 
  # threshold cutoff
  sdm_model_eval <- predicts::pa_evaluate(p = data[group_presence == testing_group, ],
                                          a = background_points[group_background == testing_group, ],
                                          model = sdm_model,
                                          x = bioclim_data)
  sdm_model_threshold <- sdm_model_eval@thresholds$max_spec_sens
  
  return(list(sdm = sdm_model, sdm_threshold = sdm_model_threshold))
}
