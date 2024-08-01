# Script to run contemporary species distribution model for Papilio cresphontes & Zanthoxylum americanum
# Jeff Oliver
# jcoliver@arizona.edu
# 2024-07-31

################################################################################
# SETUP
# Gather path information
# Load dependencies

# Things to set:
butterfly_data_file <- "data/Papilio_cresphontes_data.csv"
plant_data_file <- "data/Zanthoxylum_americanum_data.csv"
outprefix <- "Papilio_cresphontes"
outpath <- "output/"

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

# Load dependancies, keeping track of any that fail
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
butterfly_data <- PrepareData(file = butterfly_data_file)
plant_data <- PrepareData(file = plant_data_file)

# Run species distribution modeling
butterfly_raster <- SDMRaster(data = butterfly_data)
plant_raster <- SDMRaster(data = plant_data)

# Combine results from butterflies and plants
combined_raster <- StackTwoRasters(raster1 = butterfly_raster,
                                   raster2 = plant_raster)

# Calculate the % of plant range occupied by butterfly
pixel_freqs <- terra::freq(combined_raster)
plants <- pixel_freqs[which(pixel_freqs[, 2] == 2), 3]
both <- pixel_freqs[which(pixel_freqs[, 2] == 3), 3]
plant_percent <- round(100 * (both/(plants + both)), 2)

################################################################################
# PLOT
# Determine size of plot
# Plot to pdf file

# Add small value to all raster pixels so plot is colored correctly
combined_raster <- combined_raster + 0.00001

# Determine the geographic extent of our plot
xmin <- terra::ext(combined_raster)[1]
xmax <- terra::ext(combined_raster)[2]
ymin <- terra::ext(combined_raster)[3]
ymax <- terra::ext(combined_raster)[4]

# Plot the models for butterfly, plant and overlap; save to pdf
plot_file <- paste0(outpath, outprefix, "-pairwise-prediction.pdf")
pdf(file = plot_file, useDingbats = FALSE)
breakpoints <- c(0, 1, 2, 3, 4)
plot_colors <- c("white", "purple3","darkolivegreen4", "orangered4", "black")

# Get data for map borders
country_borders <- geodata::world(resolution = 4,
                                  path = "data")

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95")

# Add the model rasters
plot(combined_raster, legend = FALSE, add = TRUE, 
     breaks = breakpoints, col = plot_colors)

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

# Add the legend
terra::add_legend("topright", legend = c("Insect", "Plant", "Both"), 
                  fill = plot_colors[2:4], bg = "#FFFFFF")

# Stop re-direction to PDF graphics device
dev.off()

# Let user know analysis is done.
message(paste0("\nAnalysis complete. Map image written to ", plot_file, "."))
message(paste0("Amount of plant range occupied by insect: ", plant_percent, "%."))