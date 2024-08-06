# Run all examples in scripts/examples
# Jeff Oliver
# jcoliver@arizona.edu
# 2018-06-15

################################################################################

example.files <- list.files(path = "scripts/examples", full.names = TRUE)

for (i in 1:length(example.files)) {
  message(paste0("Running script ", i, " of ", length(example.files), ": ", example.files[i]))
  source(file = example.files[i])
}
