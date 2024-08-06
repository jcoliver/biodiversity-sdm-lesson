# Setup script for required data and package installation
# Jeffrey C. Oliver
# jcoliver@arizona.edu
# 2024-07-31

################################################################################
# SUMMARY
# Install dependencies
# Download climate data

################################################################################
# Install dependencies
required <- c("terra", "geodata", "predicts")
install.packages(required)

# Make sure packages all installed
successful <- required %in% rownames(installed.packages())
unsuccessful <- required[!successful]

if (length(unsuccessful) > 0) {
  unsuccessful_string <- paste0(unsuccessful, collapse = ", ")
  stop(paste0("One or more required packages could not be installed: ", 
              unsuccessful_string))
}

################################################################################
# Download climate data

# Make sure data directory is writable
if (file.access(names = "data") != 0) {
  stop(paste0("You do not have sufficient write access to data directory.\n"))
}

# Make sure raster package was installed and load it
if (!require(package = "geodata")) {
  stop("Setup requires the geodata package, which does not appear to be available.\n")
}

# Download bioclim data
message("Downloading climate data from WorldClim")
# Get the biolim data
bioclim_data <- geodata::worldclim_global(var = "bio",
                                          res = 2.5,
                                          path = "data")

# Download forecast data
message("Downloading forecast climate data (this may take a moment)")
forecast_data <- geodata::cmip6_world(model = "GFDL-ESM4", 
                                      ssp = "370", 
                                      time = "2061-2080", 
                                      var = "bioc", 
                                      res = 2.5, 
                                      path = "data")

# Clean up workspace
rm(required, successful, unsuccessful, bioclim_data, forecast_data)

message("Setup complete.")