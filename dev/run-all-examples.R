# Run all examples in scripts/examples
# Jeff Oliver
# jcoliver@arizona.edu
# 2024-08-06

################################################################################

example_files <- list.files(path = "scripts/examples", full.names = TRUE)

for (i in 1:length(example_files)) {
  message(paste0("Running script ", i, " of ", length(example_files), ": ", example_files[i]))
  source(file = example_files[i])
}
