# Species observation point map for Zanthoxylum americanum
# Jeff Oliver
# jcoliver@arizona.edu
# 2024-07-31

################################################################################
# SETUP
# Gather path information
# Load dependencies

# Things to set:
infile <- "data/Zanthoxylum_americanum_data.csv"
outprefix <- "Zanthoxylum_americanum"
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
required_writables <- c("data", outpath)
write_access <- file.access(names = required_writables)
if (any(write_access != 0)) {
  stop(paste0("You do not have sufficient write access to one or more directories. ",
              "The following directories do not appear writable: \n",
              paste(required_writables[write_access != 0], collapse = "\n")))
}

# Load dependencies, keeping track of any that fail
required_packages <- c("terra", "geodata")
missing_packages <- character(0)
for (one_package in required_packages) {
  if (!suppressMessages(require(package = one_package, character.only = TRUE))) {
    missing_packages <- cbind(missing_packages, one_package)
  }
}

if (length(missing_packages) > 0) {
  stop(paste0("Missing one or more required packages. The following packages are required for plot-observations: ", 
              paste(missing_packages, sep = "", collapse = ", ")), ".\n")
}

source(file = "functions/sdm-functions.R")

################################################################################
# PLOT
# Prepare data
# Determine size of plot
# Plot to pdf file

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

# Plot the observations & save to pdf
plot_file <- paste0(outpath, outprefix, "-observations.pdf")
pdf(file = plot_file, useDingbats = FALSE)

# Draw the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     axes = TRUE, 
     col = "gray95",
     main = paste0("Observations of ", gsub(pattern = "_", replacement = " ", x = outprefix)))

# Add observation points
points(x = prepared_data$lon, y = prepared_data$lat, col = "#003300", 
       pch = 20, cex = 0.7)

# Redraw the borders of the base map
plot(country_borders, 
     xlim = c(xmin, xmax), 
     ylim = c(ymin, ymax), 
     add = TRUE, 
     border = "gray10", 
     col = NA)

# Stop writing to PDF
dev.off()

# Let user know plotting is done.
message(paste0("\nPlot complete. Map image written to ", plot_file, "."))
