# Papilio cresphontes observation point map
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2018-01-19



################################################################################
# SETUP
# Gather path information
# Load dependancies

# Things to set:
infile <- "data/Papilio_cresphontes_data.csv"
outprefix <- "Papilio_cresphontes"
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
required.writables <- c("data", outpath)
write.access <- file.access(names = required.writables)
if (any(write.access != 0)) {
  stop(paste0("You do not have sufficient write access to one or more directories. ",
              "The following directories do not appear writable: \n",
              paste(required.writables[write.access != 0], collapse = "\n")))
}

# Load dependancies, keeping track of any that fail
required.packages <- c("sp", "maptools")
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
# PLOT
# Prepare data
# Determine size of plot
# Plot to pdf file

# Prepare data
prepared.data <- PrepareData(file = infile)

# Determine the geographic extent of our plot
xmin <- min(prepared.data$lon)
xmax <- max(prepared.data$lon)
ymin <- min(prepared.data$lat)
ymax <- max(prepared.data$lat)

# Plot the observations & save to pdf
plot.file <- paste0(outpath, outprefix, "-observations.pdf")
pdf(file = plot.file, useDingbats = FALSE)

# Load in data for map borders
data(wrld_simpl)

# Draw the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95",
     main = paste0("Observations of ", gsub(pattern = "_", replacement = " ", x = outprefix)))

# Add observation points
points(x = prepared.data$lon, y = prepared.data$lat, col = "#003300", pch = 20, cex = 0.7)

# Redraw the borders of the base map
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", col = NA)

# Add bounding box around map
box()

# Stop writing to PDF
dev.off()

# Let user know plotting is done.
message(paste0("\nPlot complete. Map image written to ", plot.file, "."))


