# SDM image for ACIC class
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-08-30

rm(list = ls())
################################################################################
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

# Set map boundaries
max.lat = 50
min.lat = 18
max.lon = -68
min.lon = -125
geographic.extent <- extent(x = c(min.lon, max.lon, min.lat, max.lat))

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


# Do species distribution model and draw a plot
bc <- bioclim(x = bioclim.data, p = presence.train)
bc.eval <- evaluate(presence.test, bg.test, bc, bioclim.data)
bc.threshold <- threshold(bc.eval, "spec_sens")
predict.presence <- predict(x = bioclim.data, object = bc, ext = geographic.extent, progress = "")
data("wrld_simpl")
png(file = "output/melinus-observed.png", width = 960, height = 960)
plot(wrld_simpl, 
     xlim = c(-125, -68), 
     ylim = c(18, 50), 
     axes = TRUE, 
     col = "#F2F2F2",
     border = "dark grey",
     main = "Observed data")
points(obs.data$lon, obs.data$lat, col = "darkred", pch = 20)
box()
dev.off()

png(file = "output/melinus-predicted.png", width = 960, height = 960)
plot(wrld_simpl, 
     xlim = c(-125, -68), 
     ylim = c(18, 50), 
     axes = TRUE, 
     add = FALSE,
     col = "#F2F2F2",
     border = "dark grey",
     main = "Probability of occurrence")
plot(predict.presence, 
     add = TRUE,
     legend = FALSE)
plot(predict.presence,
     legend.only = TRUE,
     smallplot = c(0.15, 0.17, 0.2, 0.4))
plot(wrld_simpl, 
     add = TRUE, 
     border = "dark grey")
box()
dev.off()

png(file = "output/bioclim-example-plot.png", width = 960, height = 960)
plot(bioclim.data)
dev.off()
