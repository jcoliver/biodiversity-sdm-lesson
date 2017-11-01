# Script to run Species Distribution Model using "bioclim" approach
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-09-07

rm(list = ls())

################################################################################
# SETUP
# Gather path information
# Load dependancies

# Things to set:
# TODO: 
# change infile -> butterfly.data.file
# make plant.data.file
# update the outprefix
# write code for overlap map

butterfly.data.file <- "data/BUTTERFLY_DATA.csv"
plant.data.file <- "data/PLANT_DATA.csv"
outprefix <- "MY_SPECIES"
outpath <- "output/"

# TESTING REPLACE
butterfly.data.file <- "data/L_xanthoides.csv"
plant.data.file <- "data/R_salicifolius.csv"
outprefix <- "L_xanthoides"


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

source(file = "functions/prepareData.R")

################################################################################
# DATA
# Read in raw data
# Extract data of interest
# Data cleanup and extent
# Create pseudo-absence points

butterfly.data <- PrepareData(file = butterfly.data.file)
plant.data <- PrepareData(file = plant.data.file)

butterfly.raster <- SDMRaster(data = butterfly.data)
plant.raster <- SDMRaster(data = plant.data)

combined.raster <- StackTwoRasters(raster1 = butterfly.raster,
                                   raster2 = plant.raster)

# TODO: figure out why raster summation is requiring this extra addition
# Maybe an issue with plot, where breakpoints are inclusive on the 
# lower end:
# 0 <= x <= 1 colored as 0
# 1 < x <= 2 colored as 1
# 2 < x <= 3 colored as 2
# 3 < x <= 4 colored as 3
# This is likely the problem, as the addition below produces a map with 
# the expected (desired) colors:
combined.raster <- combined.raster + 0.00001

xmin <- extent(combined.raster)[1]
xmax <- extent(combined.raster)[2]
ymin <- extent(combined.raster)[3]
ymax <- extent(combined.raster)[4]

# Load in data for map borders
# png(file = "~/Desktop/combined.png")
pdf(file = "~/Desktop/combined.pdf", useDingbats = FALSE)
breakpoints <- c(0, 1, 2, 3, 4)
plot.colors <- c("white", "plum3","darkolivegreen3", "orangered4", "black")

data(wrld_simpl)
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95")
plot(combined.raster, add = TRUE, breaks = breakpoints, col = plot.colors)
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", col = NA)
dev.off()
