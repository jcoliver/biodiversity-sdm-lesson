# Script to download file of observations from iNaturalist based on taxon_id
# Jeff Oliver
# jcoliver@arizona.edu
# 2024-07-31

################################################################################
args = commandArgs(trailingOnly = TRUE)
usage_string <- "Usage: Rscript --vanilla scripts/get-observation-data.R <taxon_id>"

if (length(args) < 1) {
  stop(paste("get-observation-data requires a numerical taxon id", 
             usage_string,
             sep = "\n"))
}

inat_taxon_id <- args[1]
if (is.na(suppressWarnings(as.numeric(inat_taxon_id)))) {
  stop(paste0("get-observation-data requires a numerical taxon id\n",
              "\"", inat_taxon_id, "\" is not a valid id\n",
              usage_string,
              "\n"))
}

page_num <- 1
finished <- FALSE
obs_data <- NULL
# Retrieving information from iNaturalist API
# Don't know a priori how many pages of records there will be, so for now we'll
# just keep doing GET requests, incrementing the `page` key until we get a 
# result with zero observations (up to 99 requests, more than that requires 
# authentication)
while (!finished & page_num < 100) {
  obs_url <- paste0("http://inaturalist.org/observations.csv?&taxon_id=", 
                    inat_taxon_id, 
                    "&page=", 
                    page_num,
                    "&quality_grade=research&has[]=geo")
  temp_data <- read.csv(file = obs_url, stringsAsFactors = FALSE)
  if (nrow(temp_data) > 0) {
    if (is.null(obs_data)) {
      obs_data <- temp_data
    } else {
      obs_data <- rbind(obs_data, temp_data)
    }
  } else {
    finished <- TRUE
  }
  page_num <- page_num + 1
  rm(temp_data)
}

# As long as there are records, write them to file
if (nrow(obs_data) > 0) {
  if (!dir.exists("data")) {
    dir.create("data")
  }
  if (!dir.exists("data/inaturalist")) {
    dir.create("data/inaturalist")
  }
  outfile <- paste0("data/inaturalist/", inat_taxon_id, "-iNaturalist.txt")
  write.csv(x = obs_data, 
            file = outfile,
            row.names = FALSE,
            quote = TRUE) # Gotta quote strings, as they are likely to contain common seps (i.e. "," and "\t")
  cat(paste0(nrow(obs_data), " records for taxon id ", inat_taxon_id, " written to ", outfile, "\n"))
} else {
  cat(paste0("No records returned for taxon id = ", inat_taxon_id, "\n"))
}
