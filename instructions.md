# Species Distribution Modeling
## Instructions

### Installations
1. Install R
2. Install RStudio
3. Install Git

### Setup
1. In RStudio, clone the Git repository at [https://github.com/jcoliver/biodiversity-sdm-lesson.git](https://github.com/jcoliver/biodiversity-sdm-lesson.git)
2. Download data for **butterfly** species from iNaturalist as a CSV file, save it in the `biodiversity-sdm-lesson/data` folder
3. Download data for **plant** species from iNaturalist as a CSV file, save it in the `biodiversity-sdm-lesson/data` folder

### Running analyses
1. Copy the file `run-sdm-pairwise.R` and rename the copy `<species>-sdm-pairwise.R`, replacing `<single>` with the name of the butterfly species. Use underscores instead of spaces; so for the species _L. xanthoides_, the file name would be `L_xanthoides-sdm-pairwise.R`.
2. Open this new file and update the following values:
    1. `butterfly.data.file <- "../data/BUTTERFLY_DATA.csv"`
    Change `"BUTTERFLY_DATA.csv"` so it matches the file of butterfly data you saved in [Setup](#setup), step 2.
    2. `plant.data.file <- "../data/PLANT_DATA.csv"`
    Change `"PLANT_DATA.csv"` so it matches the file of plant data you saved in [Setup](#setup), step 3.
    3. `outprefix <- "MY_SPECIES"` 
    Replace `"MY_SPECIES"` with the name of the butterfly species. Use underscores instead of spaces; so for the species _L. xanthoides_, the line would read: 
    `outprefix <- "L_xanthoides"`
    4. Save the file with these updates
3. Run the analyses by typing the following command in the **Console**: `source(file = "scripts/<species>-sdm-pairwise.R")`, replacing `<species>` with the species name as in step 1 of [Running analyses](#running-analyses)