# Processing shapefile for downloading OB data from GEE

limit_gee_sub_area <- function(shapefile, 
                               data,
                               district = NULL,
                               crs = NULL){
  
  if(!is.null(district)){
    study_sh <- subset(shapefile, (ADM2_EN==district))
  } 
  
  study_sh <- st_transform(study_sh, crs = crs)
  subset_households <- st_intersection(study_sh, buildings)
  
  if(!is.null(district)){
    assign(paste0(district, "_buildings"), subset_households, envir = .GlobalEnv)
  } else {
    assign("buildings", subset_households, envir = .GlobalEnv)
  }
}