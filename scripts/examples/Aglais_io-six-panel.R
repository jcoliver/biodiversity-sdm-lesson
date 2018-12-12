# Script for six-panel figure of Aglais io & Urtica dioica
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-09-07



################################################################################
# SETUP
# Gather path information
# Load dependancies

# Things to set:
butterfly.data.file <- "data/Aglais_io_data.csv"
plant.data.file <- "data/Urtica_dioica_data.csv"
butterfly.species <- "Aglais_io"
plant.species <- "Urtica_dioica"
outpath <- "output/"

# Make sure the input files exist
if (!file.exists(butterfly.data.file)) {
  stop(paste0("Cannot find ", butterfly.data.file, ", file does not exist.\n"))
}
if (!file.exists(plant.data.file)) {
  stop(paste0("Cannot find ", plant.data.file, ", file does not exist.\n"))
}

# Make sure the input files are readable
if (file.access(names = butterfly.data.file, mode = 4) != 0) {
  stop(paste0("You do not have sufficient access to read ", butterfly.data.file, "\n"))
}
if (file.access(names = plant.data.file, mode = 4) != 0) {
  stop(paste0("You do not have sufficient access to read ", plant.data.file, "\n"))
}

# Make sure the output path ends with "/" (and append one if it doesn't)
if (substring(text = outpath, first = nchar(outpath), last = nchar(outpath)) != "/") {
  outpath <- paste0(outpath, "/")
}

# Make sure directories are writable
required.writables <- c("data", outpath)
write.access <- file.access(names = required.writables)
if (any(write.access != 0)) {
  stop(paste0("You do not have sufficient write access to one or more directories. ",
              "The following directories do not appear writable: \n",
              paste(required.writables[write.access != 0], collapse = "\n")))
}

# Load dependancies, keeping track of any that fail
required.packages <- c("raster", "sp", "dismo", "maptools")
missing.packages <- character(0)
for (one.package in required.packages) {
  if (!suppressMessages(require(package = one.package, character.only = TRUE))) {
    missing.packages <- cbind(missing.packages, one.package)
  }
}

if (length(missing.packages) > 0) {
  stop(paste0("Missing one or more required packages. The following packages are required for run-sdm: ", paste(missing.packages, sep = "", collapse = ", ")), ".\n")
}

source(file = "functions/sdm-functions.R")

################################################################################
# ANALYSIS
# Prepare data
# Run SDMs
# Combine SDMs

message("Starting species distribution modeling")

# Prepare data
butterfly.data <- PrepareData(file = butterfly.data.file)
plant.data <- PrepareData(file = plant.data.file)

# Run species distribution modeling, contemporary
butterfly.raster.current <- SDMRaster(data = butterfly.data)
plant.raster.current <- SDMRaster(data = plant.data)
# Combine the two rasters into one
combined.raster.current <- StackTwoRasters(raster1 = butterfly.raster.current,
                                           raster2 = plant.raster.current)
# Add small value to all raster pixels so plot is colored correctly
combined.raster.current <- combined.raster.current + 0.00001

# Change zeros to NAs
butterfly.raster.current[butterfly.raster.current <= 0] <- NA
plant.raster.current[plant.raster.current <= 0] <- NA

# Add small value to all raster pixels so plot is colored correctly
butterfly.raster.current <- butterfly.raster.current + 0.00001
plant.raster.current <- plant.raster.current + 0.00001

# Run species distribution modeling, future
butterfly.raster.future <- SDMForecast(data = butterfly.data)
plant.raster.future <- SDMForecast(data = plant.data)
# Combine the two rasters into one
combined.raster.future <- StackTwoRasters(raster1 = butterfly.raster.future,
                                           raster2 = plant.raster.future)
# Add small value to all raster pixels so plot is colored correctly
combined.raster.future <- combined.raster.future + 0.00001

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
plot.file <- paste0(outpath, butterfly.species, "-six-panel.pdf")
pdf(file = plot.file, useDingbats = FALSE)

# Setup plot
par(mfrow = c(3, 2),
    cex.main = 0.95,
    cex.axis = 0.8,
    las = 1,
    mar = c(3, 4, 3, 2) + 0.1)
butterfly.color <- "purple3"
plant.color <- "darkolivegreen4"
overlap.color <- "orangered4"
legend.cex = 0.6

# Load in data for map borders
data(wrld_simpl)

################################################################################
# PLOT 1: Observation of butterfly species

# Determine the geographic extent of our plot
xmin <- min(butterfly.data$lon)
xmax <- max(butterfly.data$lon)
ymin <- min(butterfly.data$lat)
ymax <- max(butterfly.data$lat)

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95", border = "gray10", lwd = 0.5,
     main = paste0("Observations of ", gsub(pattern = "_", replacement = " ", x = butterfly.species)))

# Add observation points
points(x = butterfly.data$lon, y = butterfly.data$lat, col = "#003300", pch = 21, cex = 0.7, 
       bg = butterfly.color, lwd = 0.5)

# Add bounding box around map
box()

################################################################################
# PLOT 2: Observation of plant species

# Determine the geographic extent of our plot
xmin <- min(plant.data$lon)
xmax <- max(plant.data$lon)
ymin <- min(plant.data$lat)
ymax <- max(plant.data$lat)

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95", border = "gray10", lwd = 0.5,
     main = paste0("Observations of ", gsub(pattern = "_", replacement = " ", x = plant.species)))

# Add observation points
points(x = plant.data$lon, y = plant.data$lat, col = "#003300", pch = 21, cex = 0.7,
       bg = plant.color, lwd = 0.5)

# Add bounding box around map
box()

################################################################################
# PLOT 3: Contemporary SDM of butterfly species

# Determine the geographic extent of our plot
xmin <- extent(butterfly.raster.current)[1]
xmax <- extent(butterfly.raster.current)[2]
ymin <- extent(butterfly.raster.current)[3]
ymax <- extent(butterfly.raster.current)[4]

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95", border = NA,
     main = paste0(gsub(pattern = "_", replacement = " ", x = butterfly.species), " - current"))

# Add the model rasters
plot(butterfly.raster.current, legend = FALSE, add = TRUE, breaks = c(0, 1, 2), col = c("white", butterfly.color, "white"))

# Redraw the borders of the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", lwd = 0.5, col = NA)

# Add bounding box around map
box()

################################################################################
# PLOT 4: Contemporary SDM of plant species

# Determine the geographic extent of our plot
xmin <- extent(plant.raster.current)[1]
xmax <- extent(plant.raster.current)[2]
ymin <- extent(plant.raster.current)[3]
ymax <- extent(plant.raster.current)[4]

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95", border = NA,
     main = paste0(gsub(pattern = "_", replacement = " ", x = plant.species), " - current"))

# Add the model rasters
plot(plant.raster.current, legend = FALSE, add = TRUE, breaks = c(0, 1, 2), col = c("white", plant.color, "white"))

# Redraw the borders of the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", lwd = 0.5, col = NA)

# Add bounding box around map
box()

################################################################################
# PLOT 5: Contemporary SDMs of butterfly & plant species with overlap

# Determine the geographic extent of our plot
xmin <- extent(combined.raster.current)[1]
xmax <- extent(combined.raster.current)[2]
ymin <- extent(combined.raster.current)[3]
ymax <- extent(combined.raster.current)[4]

# Coloring breakpoints
breakpoints <- c(0, 1, 2, 3, 4)
plot.colors <- c("white", butterfly.color, plant.color, overlap.color, "white")

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95", border = NA, 
     main = "Combined Contemporary SDMs")

# Add the model rasters
plot(combined.raster.current, 
     legend = FALSE, 
     add = TRUE, 
     breaks = breakpoints, 
     col = plot.colors)

# Redraw the borders of the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", lwd = 0.5, col = NA)

# Add the legend
legend("topright", legend = c(gsub(pattern = "_", replacement = " ", x = butterfly.species), 
                              gsub(pattern = "_", replacement = " ", x = plant.species), 
                              "Overlap"), 
       fill = plot.colors[2:4], 
       bg = "#FFFFFF",
       cex = legend.cex)

# Add bounding box around map
box()

################################################################################
# PLOT 6: Forecast SDMs of butterfly & plant species with overlap

# Determine the geographic extent of our plot
xmin <- extent(combined.raster.future)[1]
xmax <- extent(combined.raster.future)[2]
ymin <- extent(combined.raster.future)[3]
ymax <- extent(combined.raster.future)[4]

# Coloring breakpoints
breakpoints <- c(0, 1, 2, 3, 4)
plot.colors <- c("white", butterfly.color, plant.color, overlap.color, "white")

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95", border = NA,
     main = "Combined Forecast SDMs")

# Add the model rasters
plot(combined.raster.future, 
     legend = FALSE, 
     add = TRUE, 
     breaks = breakpoints, 
     col = plot.colors)

# Redraw the borders of the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", lwd = 0.5, col = NA)

# Add the legend
legend("topright", legend = c(gsub(pattern = "_", replacement = " ", x = butterfly.species), 
                              gsub(pattern = "_", replacement = " ", x = plant.species), 
                              "Overlap"), 
       fill = plot.colors[2:4], 
       bg = "#FFFFFF",
       cex = legend.cex)

# Add bounding box around map
box()

# Reset default graphics parameters
par(mfrow = c(1, 1),
    cex.main = 1.0,
    cex.lab = 1.0,
    las = 0,
    mar = c(5, 4, 4, 2) + 0.1)

# Stop re-direction to PDF
dev.off()

# Let user know analysis is done.
message(paste0("Analysis and plotting complete; images written to ", plot.file))
