# Create documentation images
# Jeff Oliver
# jcoliver@arizona.edu
# 2024-08-05

# Creates the four images used in docs/instructions.md, namely:
#   + img/Papilio_cresphontes-current-single.png
#   + img/Papilio_cresphontes-current-pairwise.png
#   + img/Papilio_cresphontes-future-single.png
#   + img/Papilio_cresphontes-future-pairwise.png

################################################################################
# Setup

# Load dependencies
if (!require(terra)) {
  stop("The creation of documentation images requires the terra package.")
}
if (!require(geodata)) {
  stop("The creation of documentation images requires the geodata package.")
}
if (!require(predicts)) {
  stop("The creation of documentation images requires the predicts package.")
}

# Load custom functions
source(file = "functions/sdm-functions.R")

# Data file information
butterfly_data_file <- "data/Papilio_cresphontes_data.csv"
plant_data_file <- "data/Zanthoxylum_americanum_data.csv"
butterfly_species <- "Papilio_cresphontes"
plant_species <- "Zanthoxylum_americanum"
outpath <- "img/"

# Make sure the input files exist
if (!file.exists(butterfly_data_file)) {
  stop(paste0("Cannot find ", butterfly_data_file, ", file does not exist.\n"))
}
if (!file.exists(plant_data_file)) {
  stop(paste0("Cannot find ", plant_data_file, ", file does not exist.\n"))
}

# Prepare data
butterfly_data <- PrepareData(file = butterfly_data_file)
plant_data <- PrepareData(file = plant_data_file)

################################################################################
# Run species distribution modeling

# Run species distribution modeling, contemporary
message("Running contemporary SDMS...")
butterfly_raster_current <- SDMRaster(data = butterfly_data)
plant_raster_current <- SDMRaster(data = plant_data)

# Combine the two rasters into one
combined_raster_current <- StackTwoRasters(raster1 = butterfly_raster_current,
                                           raster2 = plant_raster_current)

# Run forecast modeling
message("Running forecast SDMs...")
butterfly_raster_future <- SDMForecast(data = butterfly_data)
plant_raster_future <- SDMForecast(data = plant_data)

# Combine the two rasters into one
combined_raster_future <- StackTwoRasters(raster1 = butterfly_raster_future,
                                          raster2 = plant_raster_future)

# Change zeros to NAs in contemporary single-species rasters (for plotting)
butterfly_raster_current[butterfly_raster_current <= 0] <- NA
butterfly_raster_future[butterfly_raster_future <= 0] <- NA

# Add small value to all raster pixels so plot is colored correctly
butterfly_raster_current <- butterfly_raster_current + 0.00001
butterfly_raster_future <- butterfly_raster_future + 0.00001
combined_raster_current <- combined_raster_current + 0.00001
combined_raster_future <- combined_raster_future + 0.00001

################################################################################
# Plotting
message("Writing plots")

# Setup colors for figures
butterfly_color <- "purple3"
plant_color <- "darkolivegreen4"
overlap_color <- "orangered4"
legend_cex = 0.7

# Get data for map borders
country_borders <- geodata::world(resolution = 4,
                                  path = "data")

########################################
# PLOT 1: Contemporary SDM of butterfly species

plot1_file <- paste0(outpath, "/", butterfly_species, "-current-single.png")

# Determine the geographic extent of our plot
xmin <- terra::ext(butterfly_raster_current)[1]
xmax <- terra::ext(butterfly_raster_current)[2]
ymin <- terra::ext(butterfly_raster_current)[3]
ymax <- terra::ext(butterfly_raster_current)[4]

png(filename = plot1_file, height = 480, width = 480, units = "px")

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
dev.off()

########################################
# PLOT 2: Contemporary SDM of butterfly species with host plant

plot2_file <- paste0(outpath, "/", butterfly_species, "-current-pairwise.png")

# Determine the geographic extent of our plot
xmin <- terra::ext(combined_raster_current)[1]
xmax <- terra::ext(combined_raster_current)[2]
ymin <- terra::ext(combined_raster_current)[3]
ymax <- terra::ext(combined_raster_current)[4]

# Coloring breakpoints
breakpoints <- c(0, 1, 1.9, 2.9, 3.9, 4)
plot_colors <- c(NA, butterfly_color, plant_color, overlap_color, NA)

png(filename = plot2_file, height = 480, width = 480, units = "px")

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

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

# Add the legend
terra::add_legend("topright", 
                  legend = c("Insect", 
                             "Plant", 
                             "Both"), 
                  fill = plot_colors[2:4], 
                  bg = "#FFFFFF",
                  cex = legend_cex)

dev.off()

########################################
# PLOT 3: Forecast SDM of butterfly species

plot3_file <- paste0(outpath, "/", butterfly_species, "-future-single.png")

# Determine the geographic extent of our plot
xmin <- terra::ext(butterfly_raster_future)[1]
xmax <- terra::ext(butterfly_raster_future)[2]
ymin <- terra::ext(butterfly_raster_future)[3]
ymax <- terra::ext(butterfly_raster_future)[4]

png(filename = plot3_file, height = 480, width = 480, units = "px")

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = paste0(gsub(pattern = "_", replacement = " ", x = butterfly_species), " - future"))

# Add the model rasters
plot(butterfly_raster_future, legend = FALSE, add = TRUE, 
     col = butterfly_color)

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)
dev.off()

########################################
# PLOT 4: Forecast SDM of butterfly species with host plant

plot4_file <- paste0(outpath, "/", butterfly_species, "-future-pairwise.png")

# Determine the geographic extent of our plot
xmin <- terra::ext(combined_raster_future)[1]
xmax <- terra::ext(combined_raster_future)[2]
ymin <- terra::ext(combined_raster_future)[3]
ymax <- terra::ext(combined_raster_future)[4]

# Coloring breakpoints
breakpoints <- c(0, 1, 1.9, 2.9, 3.9, 4)
plot_colors <- c(NA, butterfly_color, plant_color, overlap_color, NA)

png(filename = plot4_file, height = 480, width = 480, units = "px")

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

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

# Add the legend
terra::add_legend("topright", 
                  legend = c("Insect", 
                             "Plant", 
                             "Overlap"), 
                  fill = plot_colors[2:4], 
                  bg = "#FFFFFF",
                  cex = legend_cex)
dev.off()