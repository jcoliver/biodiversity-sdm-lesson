# Data preparation function for running sdm on iNaturalist data
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2017-10-31

#' Read in data from files 
prepareData <- function(file) {
  # Make sure the input files exist
  if (!file.exists(file)) {
    stop(paste0("Cannot find input data file ", infile, ", file does not exist.\n"))
  }
  
  # Make sure the input files are readable
  if (file.access(names = butterfly.data.file, mode = 4) != 0) {
    stop(paste0("You do not have sufficient access to read ", butterfly.data.file, "\n"))
  }

  original.data <- read.csv(file = file,
                            stringsAsFactors = FALSE)
  if (!(any(colnames(original.data) == "longitude") 
        && any(colnames(original.data) == "latitude"))) {
    stop(paste0("Missing required column(s) in ", file, "; input file must have 'latitude' and 'longitude' columns.\n"))
  }
  
  coordinate.data <- original.data[, c("longitude", "latitude")]
  colnames(coordinate.data) <- c("lon", "lat")
  
  # Remove duplicate rows
  duplicate.rows <- duplicated(x = coordinate.data)
  coordinate.data <- coordinate.data[!duplicate.rows, ]
  
  return(coordinate.data)
}