# SDM on iNaturalist data for Lycaena xanthoides (incl. subspecies)
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-08-22

rm(list = ls())
################################################################################
# See
# https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf

library("dismo")
library("maptools") # For drawing maps

inat.taxon.id <- 50931 # S. melinus
infile <- paste0("data/inaturalist/", inat.taxon.id, "-iNaturalist.txt")

# iNaturalist data of interest are in columns "latitude" and "longitude"
iNaturalist.data <- read.csv(file = infile,
                             stringsAsFactors = FALSE)
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

# Reality check - plot points
data(wrld_simpl)
plot(wrld_simpl, xlim = c(min.lon, max.lon), ylim = c(min.lat, max.lat), axes = TRUE, col = "light yellow")
box()
points(obs.data$lon, obs.data$lat, col = "orange", pch = 20, cex = 0.75)
points(obs.data$lon, obs.data$lat, col = "red", cex = 0.75)

# Get the biolim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                        path = "data/")
bioclim.data <- crop(x = bioclim.data, y = geographic.extent)

# Deal with absence points (making them up for now, using 'background' approach)
raster.files <- list.files(path = paste0(system.file(package = "dismo"), "/ex"),
                           pattern = "grd", full.names = TRUE)
mask <- raster(raster.files[1])
# Random points (same number as our observed points)
set.seed(inat.taxon.id)
bg <- randomPoints(mask = mask, n = nrow(obs.data), ext = geographic.extent, extf = 1.25)
colnames(bg) <- c("lon", "lat")

# Reality check to make sure they're OK
plot(wrld_simpl, xlim = c(min.lon, max.lon), ylim = c(min.lat, max.lat), axes = TRUE, col = "light yellow")
box()
plot(geographic.extent, add = TRUE, col = "red")
points(bg, cex = 0.5)

# Data for observation sites (presence and background)
presence.values <- extract(x = bioclim.data, y = obs.data)
absence.values <- extract(x = bioclim.data, y = bg)

# Separate training & testing data
group.presence <- kfold(obs.data, 5)
testing.group <- 1
presence.train <- obs.data[group.presence != testing.group, ]
presence.test <- obs.data[group.presence == testing.group, ]
group.bg <- kfold(bg, 5)
bg.train <- bg[group.bg != testing.group, ]
bg.test <- bg[group.bg == testing.group, ]

# Reality check - Look at distribution of training and testing data
plot(wrld_simpl, xlim = c(min.lon, max.lon), ylim = c(min.lat, max.lat), axes = TRUE, col = "light yellow")
box()
plot(geographic.extent, add = TRUE, col = "red", lwd = 2)
points(bg.train, pch = "-", col = "magenta")
points(bg.test, pch = "-", col = "black")
points(presence.train, pch = "+", col = "green")
points(presence.test, pch = "+", col = "blue")

# Do species distribution model and draw a plot
bc <- bioclim(x = bioclim.data, p = presence.train)
bc.eval <- evaluate(presence.test, bg.test, bc, bioclim.data)
bc.threshold <- threshold(bc.eval, "spec_sens")
predict.presence <- predict(x = bioclim.data, object = bc, ext = geographic.extent, progress = "")
par(mfrow = c(1, 2))
plot(predict.presence, main = "BIOCLIM, raw")
plot(wrld_simpl, add = TRUE, border = "dark grey")
plot(predict.presence > bc.threshold, main = "Presence/Absence")
plot(wrld_simpl, add = TRUE, border = "dark grey")
points(presence.train, pch = "+", cex = 0.2)
par(mfrow = c(1, 1))