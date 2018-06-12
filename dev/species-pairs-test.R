# Testing scientific names of species to query iNaturalist
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2018-06-11

rm(list = ls())

################################################################################
# Load data
pairs.data <- read.csv(file = "data/Suggested_pairs.csv")

# Combine names of plants & butterflies, because we just want to see if there 
# are data on iNaturalist
query.table <- data.frame(latin.name = c(as.character(pairs.data$butterfly.latin), 
                                           as.character(pairs.data$plant.latin)),
                          count = 0)

# Iterate over each name, retrieving a max of ten records
for (i in 1:nrow(query.table)) {
  if (i %% 10 == 0 || i == 1 || i == nrow(query.table)) {
    message(paste0("Query #", i))
  }
  url.name <- gsub(pattern = " ", replacement = "+", x = query.table$latin.name[i])
  obs.url <- paste0("http://inaturalist.org/observations.csv?&taxon_name=", 
                    url.name,
                    "&page=",
                    1,
                    "&per_page=",
                    10)
  temp.data <- read.csv(file = obs.url, stringsAsFactors = FALSE)
  if (nrow(temp.data) == 0) {
    message(paste0("No results for ", query.table$latin.name[i]))
  } else {
    query.table$count[i] <- nrow(temp.data)
  }
  rm(temp.data)
}

if (any(query.table$count == 0)) {
  warning("Some names returned zero records")
} else {
  message("All names returned at least one record")
}
