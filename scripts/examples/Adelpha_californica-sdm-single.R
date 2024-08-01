# Script to run contemporary species distribution model for Adelpha californica
# Jeff Oliver
# jcoliver@arizona.edu
# 2024-07-31

################################################################################
# SETUP
# Gather path information
# Load dependencies

# Things to set:
infile <- "data/Adelpha_californica_data.csv"
outprefix <- "Adelpha_californica"
outpath <- "output/"

# Make sure the input file exists
if (!file.exists(infile)) {
  stop(paste0("Cannot find ", infile, ", file does not exist.\n"))
}

# Make sure the input file is readable
if (file.access(names = infile, mode = 4) != 0) {
  stop(paste0("You do not have sufficient access to read ", infile, "\n"))
}

# Make sure the output path ends with "/" (and append one if it doesn't)
if (substring(text = outpath, first = nchar(outpath), last = nchar(outpath)) != "/") {
  outpath <- paste0(outpath, "/")
}

# Make sure directories are writable
required_writables <- c("data", outpath)
write_access <- file.access(names = required_writables)
if (any(write_access != 0)) {
  stop(paste0("You do not have sufficient write access to one or more directories. ",
              "The following directories do not appear writable: \n",
              paste(required_writables[write_access != 0], collapse = "\n")))
}

# Load dependencies, keeping track of any that fail
required_packages <- c("terra", "geodata", "predicts")
missing_packages <- character(0)
for (one_package in required_packages) {
  if (!suppressMessages(require(package = one_package, character.only = TRUE))) {
    missing_packages <- cbind(missing_packages, one_package)
  }
}

if (length(missing_packages) > 0) {
  stop(paste0("Missing one or more required packages. The following packages are required for run-sdm: ", paste(missing_packages, sep = "", collapse = ", ")), ".\n")
}

source(file = "functions/sdm-functions.R")

################################################################################
# ANALYSES
# Prepare data
# Run species distribution modeling
# Combine results from butterflies and plants

# Prepare data
prepared_data <- PrepareData(file = infile)

# Run species distribution modeling
sdm_raster <- SDMRaster(data = prepared_data)

################################################################################
# PLOT
# Determine size of plot
# Plot to pdf file

# Add small value to all raster pixels so plot is colored correctly
sdm_raster <- sdm_raster + 0.00001

# Determine the geographic extent of our plot
xmin <- terra::ext(sdm_raster)[1]
xmax <- terra::ext(sdm_raster)[2]
ymin <- terra::ext(sdm_raster)[3]
ymax <- terra::ext(sdm_raster)[4]

# Plot the model; save to pdf
plot_file <- paste0(outpath, outprefix, "-single-prediction.pdf")
pdf(file = plot_file, useDingbats = FALSE)

# Get data for map borders
country_borders <- geodata::world(resolution = 4,
                                  path = "data")

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95", 
     main = paste0(gsub(pattern = "_", replacement = " ", x = outprefix), " - current"))

# Add the model rasters
plot(sdm_raster, legend = FALSE, add = TRUE, col = c("gray95", "#77CC77"))

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

# Stop re-direction to PDF graphics device
dev.off()

# Let user know analysis is done.
message(paste0("\nAnalysis complete. Map image written to ", plot_file, "."))