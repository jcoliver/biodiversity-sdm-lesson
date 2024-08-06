# Testing scientific names of species to query iNaturalist
# Jeff Oliver
# jcoliver@arizona.edu
# 2018-06-11

################################################################################
# Load data
pairs_data <- read.csv(file = "data/Suggested_pairs.csv")

# Combine names of plants & butterflies, because we just want to see if there 
# are data on iNaturalist
query_table <- data.frame(latin_name = c(as.character(pairs_data$butterfly.latin), 
                                           as.character(pairs_data$plant.latin)),
                          count = 0)

# Iterate over each name, retrieving a max of ten records
for (i in 1:nrow(query_table)) {
  if (i %% 10 == 0 || i == 1 || i == nrow(query_table)) {
    message(paste0("Query #", i))
  }
  url_name <- gsub(pattern = " ", replacement = "+", x = query_table$latin_name[i])
  obs_url <- paste0("http://inaturalist.org/observations.csv?&taxon_name=", 
                    url_name,
                    "&page=",
                    1,
                    "&per_page=",
                    10)
  temp_data <- read.csv(file = obs_url, stringsAsFactors = FALSE)
  if (nrow(temp_data) == 0) {
    message(paste0("No results for ", query_table$latin_name[i]))
  } else {
    query_table$count[i] <- nrow(temp_data)
  }
  rm(temp_data)
}

if (any(query_table$count == 0)) {
  warning("Some names returned zero records")
} else {
  message("All names returned at least one record")
}
