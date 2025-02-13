# Survey Planning Functions

R functions for random selection of households in a study area.

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

## Description of functions

The steps used to perform random household selection are broken down into a series of functions in separate R scripts, organised as follows:

* *function_study_shapefile* is used to limit a shapefile to a study area.
* *function_classification* is used when there is no clear definition of urban and rural areas but this is needed for study planning. In this function, building density is used to approximate urban and rural areas.
* *function_hh_selection* is used to perform simple random household selection.
* *function_selection_grid* is used to perform weight-based random selection of grid cells over a study area, and then simple random sampling within grid cells.
* *function_hh_replacements* is used to select replacement buildings within a pre-defined distance from the original household selection. This function requires that *function_hh_selection* or *function_selection_grid* be run.

### Disclaimers
This is still a work in progress and the code may be updated in the future. If there is a bug on the current GitHub version, just drop me an email with a screenshot.
