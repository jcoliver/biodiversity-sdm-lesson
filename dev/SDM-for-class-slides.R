# SDM images for class presentation
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2018-02-26

rm(list = ls())

################################################################################

# Re-creating images fro slide 5 of Class2Slides.pptx
# occurrence map -occurrence
# bioclim maps   -bioclim
# sdm map        -sdm
require("sp")
require("maptools")
require("raster")
require("dismo")

# Things to set:
infile <- "data/Papilio_cresphontes_data.csv"
species.name <- "Papilio cresphontes"
outprefix <- "class-2-slides"
outpath <- "img/"

source(file = "functions/sdm-functions.R")

################################################################################
# PLOT observations
# Prepare data
# Determine size of plot
# Plot to png file

# Prepare data
prepared.data <- PrepareData(file = infile)

# Determine the geographic extent of our plot
xmin <- min(prepared.data$lon)
xmax <- max(prepared.data$lon)
ymin <- min(prepared.data$lat)
ymax <- max(prepared.data$lat)

plot.file <- paste0(outpath, outprefix, "-observations.png")
png(file = plot.file)

# Load in data for map borders
data(wrld_simpl)

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95",
     main = paste0("Observations of ", species.name))

# Add observation points
points(x = prepared.data$lon, y = prepared.data$lat, col = "#003300", pch = 20, cex = 0.7)

# Redraw the borders of the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", col = NA)

# Add bounding box around map
box()

# Stop writing to PNG
dev.off()

################################################################################
# PLOT bioclim vars
# Prepare data
# Determine size of plot
# Plot to png file

# Get the bioclim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5,
                        path = "data/")

# Store geographic extent and crop the bioclim data to that region
geographic.extent <- extent(x = c(xmin, xmax, ymin, ymax))
bioclim.data <- crop(x = bioclim.data, y = geographic.extent)

# Plot the bioclim maps to PNG file
plot.file <- paste0(outpath, outprefix, "-bioclim.png")
png(file = plot.file)

plot(bioclim.data)

# Stop writing to PNG
dev.off()

################################################################################
# PLOT SDM
# Run SDM model
# Determine size of plot
# Plot to png file

# Run species distribution modeling
sdm.model <- bioclim(x = bioclim.data, p = prepared.data)

# Use model to predict probability of occurrence
predict.presence <- predict(x = bioclim.data, 
                            object = sdm.model, 
                            ext = geographic.extent, 
                            progress = "")

# Convert zero probabilities to NAs (makes map nicer)
predict.presence[predict.presence == 0] <- NA

# Plot the SDM to PNG file
plot.file <- paste0(outpath, outprefix, "-sdm.png")
png(file = plot.file)

# Load in data for map borders
data(wrld_simpl)

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95",
     main = paste0(species.name, " distribution model"))

# Add model probabilities
plot(predict.presence, add = TRUE, legend = FALSE)

# Redraw the borders of the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", col = NA)

# Add bounding box around map
box()

# Stop writing to PNG
dev.off()
