# Species Distribution Modeling
## Explanation of scripts

This document provides a more in-depth explanation of what the four species distribution modeling scripts are doing. All four scripts are documented in the actual code, so if you want _even more_ detail, feel free to look through the R code itself. If you want to know how to _use_ the scripts, visit the [Instructions](docs/instructions.md) page. If you are running into problems with installation or running the analyses, visit the [Troubleshooting](docs/troubleshooting.md) page.

The four scripts prefaced with "`run-`" in the `scripts` folder are all doing largely the same thing, but they differ in (1) the species observation data being used and (2) the climate data being used. Considering each script in turn, we start with the simplest one, and describe the remaining three in terms of modifications from this base script.

###run-sdm-single.R

+ Summary: This is the template for the creation and evaluation of a species distribution model (SDM) for a single species based on current climate data. It plots the output of this model onto a map, which is saved as a pdf file.
+ Process: 
    1. Check to make sure data files exist and the additional R packages are installed
    2. Format the data so they are analyzed appropriately
    3. Run the species distribution model
        1. Determine the geographic extent of our data and restrict analysis to that geographic scale. We do this to reduce computation time; it is a fairly safe assumption that if we are analyzing a species from the Sonoran desert of southwestern North America, we do not need to evalute suitability of the climate of northern Eurasia.
        2. Create "pseudo-absence" points. In order to evaluate the performance of the model, we need both presence points (where the species of interest is known to occur) and absence points (where the species of interest is known to _not_ occur). The challenge is that most biodiversity observation data are _presence only_. One common work around for coercing presence-only data for use with presence/absence approaches is to use pseudo-absence, or "background" points. While "pseudo-absence" sounds fancy, it really just means that one randomly samples points from a given geographic area and treats them like locations where the species of interest is absent. A great resource investigating the influence and best practices of pseudo-absence points is a study by Barbet-Massin et al. (2012) (see [Additional Resources](#additional-resources) below for full details).
        3. Divide data into a "training" set and a "testing" set. Because we will need to evaluate the performance of the SDM, we reserve some portion of the observation data (and pseudo-absence data), in this case 20% of the observations; this is the "testing" data. The remaining 80% of the observations are used for "training" the SDM. These _independent_ data sets afford an unbiased evaluation of the models.
        4. Using the bioclim approach and the training data, estimate the effects of the climate variables on the probability that our species of interest will occur in a given location. From an abstract perspective, we are building a model
                
        _y = b<sub>1</sub>x<sub>1</sub> + b<sub>2</sub>x<sub>2</sub> + b<sub>3</sub>x<sub>3</sub> + ... + b<sub>k</sub>x<sub>k</sub>_

        Where _x<sub>i</sub>_ is the value of the _i<super>th</super>_ climate variable (e.g. annual rainfall) for a particular geographic location and _b<sub>i</sub>_ is the slope for the effect of that climate variable on the probability of presence of the species of interest at a particular geographic location. Whew! You can find out more about the bioclim algorithm in the [documentation for the dismo package](https://www.rdocumentation.org/packages/dismo/versions/1.1-4/topics/bioclim). 
        5. Using the training data, including presence points and the randomly-generated pseudo-absence points, evaluate the SDM. This compares the probability of presence estimated by the SDM at a particular geographic location to the actual presence and (psuedo-)absence of the species of interest. Note this evaluation _only_ considers locations for which we actually have data (presence or pseudo-absence).
        6. Use the climate data to predict the probability of presence at **every** point in the geographic area of interest.
    4. Plot the results of the species distribution model on a map and save it to a PDF file.

###run-future-sdm-single.R
###run-sdm-pairwise.R
###run-future-sdm-pairwise.R

## Additional Resources
+ [A study on the effect of pseudo-absences in SDMs (Barbet-Massin et al. 2012)](https://dx.doi.org/10.1111/j.2041-210X.2011.00172.x)