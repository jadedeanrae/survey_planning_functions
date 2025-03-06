# Survey Planning Functions

R functions for random selection of households in a study area.

## Description of functions

The steps used to perform random household selection are broken down into a series of functions in separate R scripts, organised as follows:

* *function_study_shapefile* is used to limit a shapefile to a study area.
* *function_classification* is used when there is no clear definition of urban and rural areas but this is needed for study planning. In this function, building density is used to approximate urban and rural areas.
* *function_hh_selection* is used to perform simple random household selection.
* *function_selection_grid* is used to perform a weighted random selection (probability proportional to size) of grid cells over a study area and then simple random sampling within grid cells.
* *function_hh_replacements* is used to select replacement buildings within a pre-defined distance from the original household selection. **This function requires that household selection is done first (by running *function_hh_selection* or *function_selection_grid***).
* *function_organisation_hh_groupings* is used to identify groupings of buildings within a pre-defined distance for the purpose of planning survey timeline. 

### Disclaimers
This is still a work in progress and the code may be updated in the future. If there is a bug on the current GitHub version, just drop me an email with a screenshot.
