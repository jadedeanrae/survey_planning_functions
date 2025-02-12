# Survey Planning Functions

R functions developed to assist in the planning of household surveys in areas lacking a complete household listing.

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

## Description of functions
### function_hh_selection
This code is used to randomly select buildings from the Open Buildings dataset, including a selection of two random replacements.

*Some steps are required before using this code*

**1. Study area shapefile**
- Download a shapefile for the study area
- You may need to process the shapefile in R (limit the shapefile to the specific area of interest)

**2. Input shapefile into the Google Earth Engine (GEE)**
- Open the GEE (https://code.earthengine.google.com)
- On the left-hand panel, select "Assets" and upload the study area shapefile and associated files (.shp, .dbf, .prj, .shx)
- Import the shapefile into the script

**3. Run script to access the Open Buildings dataset for the study area**
- Paste the script in "GEE_script" into the window
- On the right-hand panel, select "Tasks" and press "Run" on the unsubmitted task
- This will download the Open Buildings dataset to your Google Drive. This data is then used in both R scripts. 

### function_classification
This code is used to define urban and rural areas for studies which require a definition.

## Current state
Beware: this code is currently under development. Please email me (jade.rae@bnitm.de) if you find any bugs. 
