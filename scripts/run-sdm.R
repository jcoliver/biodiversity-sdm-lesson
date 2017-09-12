# Script to run Species Distribution Model using "bioclim" approach
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-09-07

rm(list = ls())

################################################################################
# SETUP
# Gather path information
# Load dependancies
args = commandArgs(trailingOnly = TRUE)
usage.string <- "Usage: Rscript --vanilla run-sdm.R <path/to/data/file> <output-file-prefix> <path/to/output/directory/>"

# Make sure a readable file is first argument
if (length(args) < 1) {
  stop(paste("run-sdm requires an input file", 
             usage.string,
             sep = "\n"))
}

infile <- args[1]
if (!file.exists(infile)) {
  stop(paste0("Cannot find ", infile, ", file does not exist.\n", usage.string, "\n"))
}

if (file.access(names = infile, mode = 4) != 0) {
  stop(paste0("You do not have sufficient access to read ", infile, "\n"))
}

# Make sure the second argument is there for output file prefix
if (length(args) < 2) {
  stop(paste("run-sdm requires an output file prefix",
             usage.string,
             sep = "\n"))
}
outprefix <- args[2]

# Make sure the third argument is there for output directory
if (length(args) < 3) {
  stop(paste("run-sdm requires an output directory",
             usage.string,
             sep = "\n"))
}
outpath <- args[3]
# Make sure the path ends with "/"
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

################################################################################
# DATA
# Read in raw data
# Extract data of interest
# Data cleanup and extent
# Create pseudo-absence points
iNaturalist.data <- read.csv(file = infile,
                             stringsAsFactors = FALSE)
if (!(any(colnames(iNaturalist.data) == "longitude") 
    && any(colnames(iNaturalist.data) == "latitude"))) {
  stop("Missing required column(s); input file must have 'latitude' and 'longitude' columns.\n")
}

obs.data <- iNaturalist.data[, c("longitude", "latitude")]
colnames(obs.data) <- c("lon", "lat")

# Remove duplicate rows
duplicate.rows <- duplicated(x = obs.data)
obs.data <- obs.data[!duplicate.rows, ]

# Determine geographic extent of our data
max.lat = ceiling(max(obs.data$lat))
min.lat = floor(min(obs.data$lat))
max.lon = ceiling(max(obs.data$lon))
min.lon = floor(min(obs.data$lon))
geographic.extent <- extent(x = c(min.lon, max.lon, min.lat, max.lat))

# Get the biolim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                        path = "data/")
bioclim.data <- crop(x = bioclim.data, y = geographic.extent)

# Create pseudo-absence points (making them up, using 'background' approach)
raster.files <- list.files(path = paste0(system.file(package = "dismo"), "/ex"),
                           pattern = "grd", full.names = TRUE)
mask <- raster(raster.files[1])

# Random points for background (same number as our observed points)
set.seed(19470909)
bg <- randomPoints(mask = mask, n = nrow(obs.data), ext = geographic.extent, extf = 1.25)
colnames(bg) <- c("lon", "lat")

# Data for observation sites (presence and background)
presence.values <- extract(x = bioclim.data, y = obs.data)
absence.values <- extract(x = bioclim.data, y = bg)

################################################################################
# ANALYSIS
# Divide data into testing and training
# Run SDM
# Save graphics and raster files

# Separate training & testing data
group.presence <- kfold(obs.data, 5)
testing.group <- 1
presence.train <- obs.data[group.presence != testing.group, ]
presence.test <- obs.data[group.presence == testing.group, ]
group.bg <- kfold(bg, 5)
bg.train <- bg[group.bg != testing.group, ]
bg.test <- bg[group.bg == testing.group, ]

# Do species distribution modeling
bc <- bioclim(x = bioclim.data, p = presence.train)
bc.eval <- evaluate(presence.test, bg.test, bc, bioclim.data)
bc.threshold <- threshold(bc.eval, "spec_sens")
predict.presence <- predict(x = bioclim.data, object = bc, ext = geographic.extent, progress = "")

# Save image to file
data(wrld_simpl) # Need this for the map
png(filename = paste0(outpath, outprefix, "-prediction.png"))
par(mar = c(3, 3, 3, 1) + 0.1)
plot(wrld_simpl, 
     xlim = c(min.lon, max.lon), 
     ylim = c(min.lat, max.lat), 
     col = "#F2F2F2",
     axes = TRUE)
plot(predict.presence > bc.threshold, 
     main = "Presence/Absence",
     legend = FALSE,
     add = TRUE)
plot(wrld_simpl, 
     add = TRUE,
     border = "dark grey")
box()
par(mar = c(5, 4, 4, 2) + 0.1)
dev.off()

# Save raster to files
suppressMessages(writeRaster(x = predict.presence, 
                             filename = paste0(outpath, outprefix, "-prediction.grd"),
                             format = "raster",
                             overwrite = TRUE))

suppressMessages(writeRaster(x = predict.presence > bc.threshold, 
                             filename = paste0(outpath, outprefix, "-prediction-threshold.grd"),
                             format = "raster",
                             overwrite = TRUE))
cat("Finished with file writing.\n")