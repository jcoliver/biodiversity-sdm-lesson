# Development script preparing forcast data for version control on GitHub
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2018-11-30

rm(list = ls())

################################################################################
# Rationale: Forecast climate data are available in tif files, which require the 
# rgdal R package (and OS-specific gdal binary) for processing. To remove this 
# dependency on rgdal, will need to download tif files, convert to rasters, 
# archive rasters, then add to version control. Extracting archives then becomes
# part of scripts/setup.R

#' 1. load (install) rgdal
#' 2. Use getData code to download tif files of forecast climate data
#' 3. Write each variable to separate raster (.gri) file, using `bylayer = TRUE`
#'    in `writeRaster`
#' 4. Create multiple zip files, say 4, with rasters, adjusting if any archive 
#'    is over 100MB
#' 5. Update scripts/setup.R to extract multiple zip files in the appropriate 
#'    directory; 
#'    create a single RasterStack item from all the .gri files;
#'    make sure .gitignore ignores the .gri and .grd files created during 
#'    extraction
#' 6. Update functions/sdm-functions.R to appropriately load in raster 
#'    (remember) to deal with names, i.e. 
#'    `names(forecast-data) <- names(bioclim.data)`
#' 7. Cleanup by removing remove rgdal

########################################
# LOAD DEPENDENCIES
rgdal.existed <- TRUE
if (!require("rgdal")) {
  rgdal.existed <- FALSE
  install.packages("rgdal")
}
library("raster")
library("rgdal")

########################################
# DOWNLOAD FORECAST DATA
forecast.data <- getData(name = "CMIP5", # forecast
                         var = "bio", # bioclim
                         res = 2.5,
                         path = "data/",
                         model = "GD", # GFDL-ESM2G
                         rcp = "45", # CO2 increase 4.5
                         year = 70) # 2070
# Also grab bioclim data so we can update names appropriately (saves headaches
# downstream)
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                        path = "data/")
names(forecast.data) <- names(bioclim.data)

########################################
# WRITE EACH LAYER TO RASTER FORMAT FILE
writeRaster(x = forecast.data, 
            filename = paste0("data/cmip5/2_5m/", names(forecast.data)), 
            bylayer = TRUE,
            format = "raster")
rm(forecast.data, bioclim.data)

########################################
# CREATE MULTIPLE ZIP FILES
raster.files <- list.files(path = "data/cmip5/2_5m", 
                           pattern = "*.gr[id]$", 
                           full.names = TRUE)

# Aiming for four archives, see how many files go in each
num.archives <- 4
archive.size <- ceiling(length(raster.files) / num.archives)
# Ensure archive has even number of files (to keep .grd and .gri files together)
if (archive.size %% 2 != 0) {
  archive.size <- archive.size + 1
}

for (i in 1:num.archives) {
  offset <- (i - 1) * archive.size
  fileindexes <- c(1:archive.size) + offset
  num.remaining.files <- length(raster.files[fileindexes[1]:length(raster.files)])
  # Fewer files, need to adjust fileindexes
  if (num.remaining.files < archive.size) {
    fileindexes <- fileindexes[1:num.remaining.files]
  }
  cat(paste0("====  Archive ", i, "  ===="), raster.files[fileindexes], sep = "\n")
  zip(zipfile = paste0("data/cmip5/2_5m/forecast", i),
      files = raster.files[fileindexes])
}

########################################
# REMOVE ALL tif, gri, AND grd FILES
obsolete.files <- list.files(path = "data/cmip5/2_5m",
                             pattern = "^gd45bi|^bio",
                             full.names = TRUE)

file.remove(obsolete.files)
if (!rgdal.existed) {
  remove.packages("rgdal")
}

########################################
# UPDATE setup.R to extract zip files
# UPDATE SDMForecast in sdm-functions.R to create RasterStack from .gri files
