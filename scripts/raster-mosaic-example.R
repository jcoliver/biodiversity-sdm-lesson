# Testing raster stacking
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-10-03

rm(list = ls())

################################################################################
library("raster")
library("maptools")

raster1 <- raster(x = "output/rasters/509627-prediction-threshold.grd")
raster2 <- raster(x = "output/rasters/59125-prediction-threshold.grd")

raster1[raster1 <= 0] <- NA
raster2[raster2 <= 0] <- NA

# Get extent
xmin <- min(extent(raster1)[1], extent(raster2)[1])
xmax <- max(extent(raster1)[2], extent(raster2)[2])
ymin <- min(extent(raster1)[3], extent(raster2)[3])
ymax <- max(extent(raster1)[4], extent(raster2)[4])

# Create a mosaic by summing pixel values
raster.mosaic <- mosaic(x = raster1, y = raster2, fun = sum)
raster.mosaic[raster.mosaic <= 0] <- NA

# Load in data for map borders
data(wrld_simpl)
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), axes = TRUE, col = "gray95")
plot(raster.mosaic, add = TRUE, col = rev(heat.colors(2)))
plot(wrld_simpl, xlim = c(xmin, xmax), ylim = c(ymin, ymax), add = TRUE, border = "gray10", col = NA)
