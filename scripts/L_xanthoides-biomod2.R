# biomod2 modeling test
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2017-11-05

rm(list = ls())

################################################################################
# Had to install slam package via terminal:
#   sudo apt-get install r-cran-slam
# In order to get biomod2 to install correctly
butterfly.data <- read.csv(file = "data/L_xanthoides.csv")


# species occurrences
DataSpecies <- read.csv(system.file("external/species/mammals_table.csv",
                                    package="biomod2"))
head(DataSpecies)

# the name of studied species
myRespName <- 'GuloGulo'

# the presence/absences data for our species 
myResp <- as.numeric(DataSpecies[,myRespName])

# the XY coordinates of species data
myRespXY <- DataSpecies[,c("X_WGS84","Y_WGS84")]


# Environmental variables extracted from BIOCLIM (bio_3, bio_4, bio_7, bio_11 & bio_12)
myExpl = stack( system.file( "external/bioclim/current/bio3.grd", 
                             package="biomod2"),
                system.file( "external/bioclim/current/bio4.grd", 
                             package="biomod2"), 
                system.file( "external/bioclim/current/bio7.grd", 
                             package="biomod2"),  
                system.file( "external/bioclim/current/bio11.grd", 
                             package="biomod2"), 
                system.file( "external/bioclim/current/bio12.grd", 
                             package="biomod2"))

# 1. Formatting Data
myBiomodData <- BIOMOD_FormatingData(resp.var = myResp,
                                     expl.var = myExpl,
                                     resp.xy = myRespXY,
                                     resp.name = myRespName)

# 2. Defining Models Options using default options.
myBiomodOption <- BIOMOD_ModelingOptions()

# 3. Doing Modelisation

myBiomodModelOut <- BIOMOD_Modeling( myBiomodData, 
                                     models = c('SRE','RF'), 
                                     models.options = myBiomodOption, 
                                     NbRunEval=2, 
                                     DataSplit=80, 
                                     VarImport=0, 
                                     models.eval.meth = c('TSS','ROC'),
                                     do.full.models=FALSE,
                                     modeling.id="test")