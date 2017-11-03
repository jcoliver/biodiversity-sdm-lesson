# Setup script for required data and package installation
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2017-11-02

################################################################################
# SUMMARY
# Install dependencies
# Download climate data

################################################################################
# Install dependencies
required <- c("raster", "sp", "dismo", "maptools")
install.packages(required)

################################################################################
# Download climate data

# Make sure data directory is writable
if (file.access(names = "data") != 0) {
  stop(paste0("You do not have sufficient write access to data directory.\n"))
}

# Make sure raster package was installed and load it
if (!require(package = "raster")) {
  stop("Setup requires the raster package, which does not appear to be available.\n")
}

# Download bioclim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                        path = "data/")

# Download forcast data
# See https://link.springer.com/article/10.1007/s00382-014-2418-8
# for recommendations of the model to use
forecast.data <- getData(name = "CMIP5", # forecast
                         var = "bio", # bioclim
                         res = 2.5,
                         path = "data/",
                         model = "GD", # GFDL-ESM2G
                         rcp = "45", # CO2 increase 4.5
                         year = 70) # 2070

# Clean up workspace
rm(required, bioclim.data, forecast.data)
