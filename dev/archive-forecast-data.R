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
#' 7. remove rgdal

########################################
# LOAD DEPENDENCIES
install.packages("rgdal")
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

########################################
# WRITE EACH LAYER TO RASTER FORMAT FILE
writeRaster(x = forecast.data, 
            filename = names(forecast.data), 
            bylayer = TRUE,
            format = "raster")

########################################
# CREATE MULTIPLE ZIP FILES

