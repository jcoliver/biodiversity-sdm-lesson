# Try 02 at SDM for eButterfly / ACIC
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-08-21

rm(list = ls())
################################################################################
# See
# https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf

library("dismo")
library("maptools") # For drawing maps

# Get the data
data.file <- paste0(system.file(package = "dismo"), "/ex/bradypus.csv")
bradypus <- read.csv(file = data.file, header = TRUE)
bradypus <- bradypus[, c(2:3)]

# TODO: Figure out extent dynamically

# Draw a map of occurrances
data(wrld_simpl)
plot(wrld_simpl, xlim = c(-90, -35), ylim = c(-25, 15), axes = TRUE, col = "light yellow")
box()
points(bradypus$lon, bradypus$lat, col = "orange", pch = 20, cex = 0.75)
points(bradypus$lon, bradypus$lat, col = "red", cex = 0.75)

# Remove duplicates
duplicate.rows <- duplicated(x = bradypus)
bradypus <- bradypus[!duplicate.rows, ]

# Deal with absence points (making them up for now, using 'background' approach)
raster.files <- list.files(path = paste0(system.file(package = "dismo"), "/ex"),
                           pattern = "grd", full.names = TRUE)
mask <- raster(raster.files[1])
# 500 random points
set.seed(20170821)
geographic.extent <- extent(x = c(-90, -35, -25, 15))
bg <- randomPoints(mask = mask, n = 500, ext = geographic.extent, extf = 1.25)
colnames(bg) <- c("lon", "lat")

# Check to make sure they're OK
plot(!is.na(mask), legend = FALSE)
plot(geographic.extent, add = TRUE, col = "red")
points(bg, cex = 0.5)

# Get the biolim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                        path = "data/")
bioclim.data <- crop(x = bioclim.data, y = geographic.extent)

# Data for observation sites (presence and background)
presence.values <- extract(x = bioclim.data, y = bradypus)
absence.values <- extract(x = bioclim.data, y = bg)

# Separate out training and testing data
group.presence <- kfold(bradypus, 5)
testing.group <- 1
presence.train <- bradypus[group.presence != testing.group, ]
presence.test <- bradypus[group.presence == testing.group, ]
group.bg <- kfold(bg, 5)
bg.train <- bg[group.bg != testing.group, ]
bg.test <- bg[group.bg == testing.group, ]

# Another visual check
r = raster(x = bioclim.data, 1)
plot(!is.na(mask), col = c("white", "light grey"), legend = FALSE)
plot(geographic.extent, add = TRUE, col = "red", lwd = 2)
points(bg.train, pch = "-", cex = 0.5, col = "yellow")
points(bg.test, pch = "-", cex = 0.5, col = "black")
points(presence.train, pch = "+", col = "green")
points(presence.test, pch = "+", col = "blue")

# Using BIOCLIM model
bc <- bioclim(x = bioclim.data, p = presence.train)
bc.eval <- evaluate(presence.test, bg.test, bc, bioclim.data)
bc.eval
bc.threshold <- threshold(bc.eval, "spec_sens")
bc.threshold
predict.presence <- predict(x = bioclim.data, object = bc, ext = geographic.extent, progress = "")
par(mfrow = c(1, 2))
plot(predict.presence, main = "BIOCLIM, raw")
plot(wrld_simpl, add = TRUE, border = "dark grey")
plot(predict.presence > bc.threshold, main = "Presence/Absence")
plot(wrld_simpl, add = TRUE, border = "dark grey")
points(presence.train, pch = "+")
par(mfrow = c(1, 2))
