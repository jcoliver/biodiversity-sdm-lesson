# Script to run contemporary species distribution model for Papilio cresphontes & Zanthoxylum americanum
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2018-01-10

rm(list = ls())

################################################################################
# SETUP
# Gather path information
# Load dependancies

butterfly.data.file <- "data/Papilio_cresphontes_data.csv"
plant.data.file <- "data/Zanthoxylum_americanum_data.csv"
outprefix <- "Papilio_cresphontes"
outpath <- "output/"

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
required.packages <- c("rgdal", "raster", "sp", "dismo", "maptools")
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
# ANALYSES
# Prepare data
# Run species distribution modeling
# Combine results from butterflies and plants

# Prepare data
butterfly.data <- PrepareData(file = butterfly.data.file)
plant.data <- PrepareData(file = plant.data.file)

# Run species distribution modeling
butterfly.raster <- SDMRaster(data = butterfly.data)
plant.raster <- SDMRaster(data = plant.data)

# Combine results from butterflies and plants
combined.raster <- StackTwoRasters(raster1 = butterfly.raster,
                                   raster2 = plant.raster)

# Calculate the % of plant range occupied by butterfly
pixel.freqs <- freq(combined.raster)
plants <- pixel.freqs[which(pixel.freqs[, 1] == 2), 2]
both <- pixel.freqs[which(pixel.freqs[, 1] == 3), 2]
plant.percent <- round(100 * (both/(plants + both)), 2)

################################################################################
# PLOT
# Determine size of plot
# Plot to pdf file

# Add small value to all raster pixels so plot is colored correctly
combined.raster <- combined.raster + 0.00001

# Determine the geographic extent of our plot
xmin <- extent(combined.raster)[1]
xmax <- extent(combined.raster)[2]
ymin <- extent(combined.raster)[3]
ymax <- extent(combined.raster)[4]

# Plot the models for butterfly, plant and overlap; save to pdf
plot.file <- paste0(outpath, outprefix, "-pairwise-prediction.pdf")
pdf(file = plot.file, useDingbats = FALSE)
breakpoints <- c(0, 1, 2, 3, 4)
plot.colors <- c("white", "plum3","darkolivegreen3", "orangered4", "black")

# Load in data for map borders
data(wrld_simpl)

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95")

# Add the model rasters
plot(combined.raster, legend = FALSE, add = TRUE, breaks = breakpoints, col = plot.colors)

# Redraw the borders of the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", col = NA)

# Add the legend
legend("topright", legend = c("Insect", "Plant", "Both"), fill = plot.colors[2:4], bg = "#FFFFFF")
dev.off()

# Let user know analysis is done.
message(paste0("\nAnalysis complete. Map image written to ", plot.file, "."))
message(paste0("Amount of plant range occupied by insect: ", plant.percent, "%."))

rm(list = ls())