# SDM images for class presentation
# Jeff Oliver
# jcoliver@arizona.edu
# 2024-08-08

################################################################################

# Re-creating images fro slide 5 of Class2Slides.pptx
# occurrence map -occurrence
# bioclim maps   -bioclim
# sdm map        -sdm
require("terra")
require("geodata")
require("predicts")

# Things to set:
infile <- "data/Papilio_cresphontes_data.csv"
species_name <- "Papilio cresphontes"
outprefix <- "class-2-slides"
outpath <- "img/"

source(file = "functions/sdm-functions.R")

################################################################################
# PLOT observations
# Prepare data
# Determine size of plot
# Plot to png file

# Prepare data
prepared_data <- PrepareData(file = infile)

# Determine the geographic extent of our plot
xmin <- min(prepared_data$lon)
xmax <- max(prepared_data$lon)
ymin <- min(prepared_data$lat)
ymax <- max(prepared_data$lat)

# Get data for map borders
country_borders <- geodata::world(resolution = 4,
                                  path = "data")

plot_file <- paste0(outpath, outprefix, "-observations.png")
png(file = plot_file)

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = paste0("Observations of ", species_name))

# Add observation points
points(x = prepared_data$lon, 
       y = prepared_data$lat, 
       col = "#003300", 
       pch = 20, cex = 0.7)

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

dev.off()

################################################################################
# PLOT bioclim vars
# Prepare data
# Determine size of plot
# Plot to png file

bioclim_data <- geodata::worldclim_global(var = "bio",
                                          res = 2.5,
                                          path = "data")

# Store geographic extent and crop the bioclim data to that region
geographic_extent <- terra::ext(x = c(xmin, xmax, ymin, ymax))
bioclim_data <- terra::crop(x = bioclim_data, y = geographic_extent)

# Plot the bioclim maps to PNG file
plot_file <- paste0(outpath, outprefix, "-bioclim.png")
png(file = plot_file)

plot(bioclim_data)

# Stop writing to PNG
dev.off()

################################################################################
# PLOT SDM
# Run SDM model
# Determine size of plot
# Plot to png file

# Run species distribution modeling (presence-only data)
# Extract climate data for observation points
presence_values <- terra::extract(x = bioclim_data, 
                                  y = prepared_data, 
                                  ID = FALSE)

# Generate species distribution model
sdm_model <- predicts::envelope(x = presence_values)

# Use model to predict probability of occurrence (can take half a minute)
predict_presence <- predict(bioclim_data, 
                            sdm_model)

# Convert zero probabilities to NAs (makes map nicer)
predict_presence[predict_presence == 0] <- NA

# Plot the SDM to PNG file
plot_file <- paste0(outpath, outprefix, "-sdm.png")
png(file = plot_file)

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = paste0(species_name, " distribution model"))

# Add model probabilities
plot(predict_presence, 
     add = TRUE, 
     legend = FALSE,
     col = map.pal(name = "inferno", n = 100))

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

# Stop writing to PNG
dev.off()
