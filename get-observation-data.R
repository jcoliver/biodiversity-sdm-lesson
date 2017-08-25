# Script to download file of observations from iNaturalist based on taxon_id
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-08-24

################################################################################
args = commandArgs(trailingOnly = TRUE)
usage.string <- "Usage: Rscript get-observation-data.R <taxon_id>"

if (length(args) < 1) {
  stop(paste("get-observation-data requires a numerical taxon id", 
             usage.string,
             sep = "\n"))
}

inat.taxon.id <- args[1]
if (is.na(suppressWarnings(as.numeric(inat.taxon.id)))) {
  stop(paste0("get-observation-data requires a numerical taxon id\n",
              "\"", inat.taxon.id, "\" is not a valid id\n",
              usage.string,
              "\n"))
}

page.num <- 1
finished <- FALSE
obs.data <- NULL
# Retrieving information from iNaturalist API
# Don't know a priori how many pages of records there will be, so for now we'll
# just keep doing GET requests, incrementing the `page` key until we get a 
# result with zero observations (up to 99 requests, more than that requires 
# authentication)
while (!finished & page.num < 100) {
  obs.url <- paste0("http://inaturalist.org/observations.csv?&taxon_id=", 
                    inat.taxon.id, 
                    "&page=", 
                    page.num,
                    "&quality_grade=research&has[]=geo")
  temp.data <- read.csv(file = obs.url)
  if (nrow(temp.data) > 0) {
    if (is.null(obs.data)) {
      obs.data <- temp.data
    } else {
      obs.data <- rbind(obs.data, temp.data)
    }
  } else {
    finished <- TRUE
  }
  page.num <- page.num + 1
  rm(temp.data)
}

# As long as there are records, write them to file
if (nrow(obs.data) > 0) {
  if (!dir.exists("data")) {
    dir.create("data")
  }
  if (!dir.exists("data/inaturalist")) {
    dir.create("data/inaturalist")
  }
  outfile <- paste0("data/inaturalist/", inat.taxon.id, "-iNaturalist.txt")
  write.table(x = obs.data, 
              file = outfile,
              row.names = FALSE,
              quote = FALSE,
              sep = "\t")
  cat(paste0(nrow(obs.data), " records for taxon id ", inat.taxon.id, " written to ", outfile, "\n"))
} else {
  cat(paste0("No records returned for taxon id = ", inat.taxon.id, "\n"))
}