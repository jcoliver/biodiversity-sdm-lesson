# Script for six-panel figure of Adelpha californica & Quercus chrysolepis
# Jeff Oliver
# jcoliver@arizona.edu
# 2024-07-31

################################################################################
# SETUP
# Gather path information
# Load dependencies

# Things to set:
butterfly_data_file <- "data/Adelpha_californica_data.csv"
plant_data_file <- "data/Quercus_chrysolepis_data.csv"
butterfly_species <- "Adelpha_californica"
plant_species <- "Quercus_chrysolepis"
outpath <- "output/"

# Make sure the input files exist
if (!file.exists(butterfly_data_file)) {
  stop(paste0("Cannot find ", butterfly_data_file, ", file does not exist.\n"))
}
if (!file.exists(plant_data_file)) {
  stop(paste0("Cannot find ", plant_data_file, ", file does not exist.\n"))
}

# Make sure the input files are readable
if (file.access(names = butterfly_data_file, mode = 4) != 0) {
  stop(paste0("You do not have sufficient access to read ", butterfly_data_file, "\n"))
}
if (file.access(names = plant_data_file, mode = 4) != 0) {
  stop(paste0("You do not have sufficient access to read ", plant_data_file, "\n"))
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
# ANALYSIS
# Prepare data
# Run SDMs
# Combine SDMs

message("Starting species distribution modeling")

# Prepare data
butterfly_data <- PrepareData(file = butterfly_data_file)
plant_data <- PrepareData(file = plant_data_file)

# Run species distribution modeling, contemporary
butterfly_raster_current <- SDMRaster(data = butterfly_data)
plant_raster_current <- SDMRaster(data = plant_data)
# Combine the two rasters into one
combined_raster_current <- StackTwoRasters(raster1 = butterfly_raster_current,
                                           raster2 = plant_raster_current)
# Add small value to all raster pixels so plot is colored correctly
combined_raster_current <- combined_raster_current + 0.00001

# Change zeros to NAs
butterfly_raster_current[butterfly_raster_current <= 0] <- NA
plant_raster_current[plant_raster_current <= 0] <- NA

# Add small value to all raster pixels so plot is colored correctly
butterfly_raster_current <- butterfly_raster_current + 0.00001
plant_raster_current <- plant_raster_current + 0.00001

# Run species distribution modeling, future
butterfly_raster_future <- SDMForecast(data = butterfly_data)
plant_raster_future <- SDMForecast(data = plant_data)
# Combine the two rasters into one
combined_raster_future <- StackTwoRasters(raster1 = butterfly_raster_future,
                                          raster2 = plant_raster_future)
# Add small value to all raster pixels so plot is colored correctly
combined_raster_future <- combined_raster_future + 0.00001

message("Species distribution modeling complete; starting plots")

################################################################################
# PLOTTING
# Setup destination
# Setup plot
# PLOT 1: Observation of butterfly species
# PLOT 2: Observation of plant species
# PLOT 3: Contemporary SDM of butterfly species
# PLOT 4: Contemporary SDM of plant species
# PLOT 5: Contemporary SDMs of butterfly & plant species with overlap
# PLOT 6: Forecast SDMs of butterfly & plant species with overlap

# Setup destination
plot_file <- paste0(outpath, butterfly_species, "-six-panel.pdf")
pdf(file = plot_file, useDingbats = FALSE)

# Setup plot
par(mfrow = c(3, 2),
    cex.main = 0.95,
    cex.axis = 0.8,
    las = 1,
    mar = c(3, 4, 3, 2) + 0.1)
butterfly_color <- "purple3"
plant_color <- "darkolivegreen4"
overlap_color <- "orangered4"
legend_cex = 0.5

# Get data for map borders
country_borders <- geodata::world(resolution = 4,
                                  path = "data")

################################################################################
# PLOT 1: Observation of butterfly species

# Determine the geographic extent of our plot
xmin <- min(butterfly_data$lon)
xmax <- max(butterfly_data$lon)
ymin <- min(butterfly_data$lat)
ymax <- max(butterfly_data$lat)

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = paste0("Observations of ", gsub(pattern = "_", replacement = " ", x = butterfly_species)))

# Add observation points
points(x = butterfly_data$lon, y = butterfly_data$lat, col = "#003300", 
       pch = 21, cex = 0.7, bg = butterfly_color, lwd = 0.5)

################################################################################
# PLOT 2: Observation of plant species

# Determine the geographic extent of our plot
xmin <- min(plant_data$lon)
xmax <- max(plant_data$lon)
ymin <- min(plant_data$lat)
ymax <- max(plant_data$lat)

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = paste0("Observations of ", gsub(pattern = "_", replacement = " ", x = plant_species)))

# Add observation points
points(x = plant_data$lon, y = plant_data$lat, col = "#003300", pch = 21, 
       cex = 0.7, bg = plant_color, lwd = 0.5)

################################################################################
# PLOT 3: Contemporary SDM of butterfly species

# Determine the geographic extent of our plot
xmin <- terra::ext(butterfly_raster_current)[1]
xmax <- terra::ext(butterfly_raster_current)[2]
ymin <- terra::ext(butterfly_raster_current)[3]
ymax <- terra::ext(butterfly_raster_current)[4]

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = paste0(gsub(pattern = "_", replacement = " ", x = butterfly_species), " - current"))

# Add the model rasters
plot(butterfly_raster_current, legend = FALSE, add = TRUE, 
     col = butterfly_color)

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

################################################################################
# PLOT 4: Contemporary SDM of plant species

# Determine the geographic extent of our plot
xmin <- terra::ext(plant_raster_current)[1]
xmax <- terra::ext(plant_raster_current)[2]
ymin <- terra::ext(plant_raster_current)[3]
ymax <- terra::ext(plant_raster_current)[4]

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = paste0(gsub(pattern = "_", replacement = " ", x = plant_species), " - current"))

# Add the model rasters
plot(plant_raster_current, legend = FALSE, add = TRUE, 
     col = plant_color)

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

################################################################################
# PLOT 5: Contemporary SDMs of butterfly & plant species with overlap

# Determine the geographic extent of our plot
xmin <- terra::ext(combined_raster_current)[1]
xmax <- terra::ext(combined_raster_current)[2]
ymin <- terra::ext(combined_raster_current)[3]
ymax <- terra::ext(combined_raster_current)[4]

# Coloring breakpoints
breakpoints <- c(0, 1, 2, 3, 4)
plot_colors <- c(NA, butterfly_color, plant_color, overlap_color, NA)

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = "Combined Contemporary SDMs")

# Add the model rasters
plot(combined_raster_current, legend = FALSE, add = TRUE, 
     breaks = breakpoints, col = plot_colors)

# Add the legend
terra::add_legend("topright", 
                  legend = c(gsub(pattern = "_", replacement = " ", x = butterfly_species), 
                             gsub(pattern = "_", replacement = " ", x = plant_species), 
                             "Overlap"), 
                  fill = plot_colors[2:4], 
                  bg = "#FFFFFF",
                  cex = legend_cex)

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

################################################################################
# PLOT 6: Forecast SDMs of butterfly & plant species with overlap

# Determine the geographic extent of our plot
xmin <- terra::ext(combined_raster_future)[1]
xmax <- terra::ext(combined_raster_future)[2]
ymin <- terra::ext(combined_raster_future)[3]
ymax <- terra::ext(combined_raster_future)[4]

# Coloring breakpoints
breakpoints <- c(0, 1, 2, 3, 4)
plot_colors <- c(NA, butterfly_color, plant_color, overlap_color, NA)

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = "Combined Forecast SDMs")

# Add the model rasters
plot(combined_raster_future, legend = FALSE, add = TRUE, 
     breaks = breakpoints, col = plot_colors)

# Add the legend
terra::add_legend("topright", 
                  legend = c(gsub(pattern = "_", replacement = " ", x = butterfly_species), 
                             gsub(pattern = "_", replacement = " ", x = plant_species), 
                             "Overlap"), 
                  fill = plot_colors[2:4], 
                  bg = "#FFFFFF",
                  cex = legend_cex)

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

# Reset default graphics parameters
par(mfrow = c(1, 1),
    cex.main = 1.0,
    cex.lab = 1.0,
    las = 0,
    mar = c(5, 4, 4, 2) + 0.1)

# Stop re-direction to PDF
dev.off()

# Let user know analysis is done.
message(paste0("Analysis and plotting complete; images written to ", plot_file))