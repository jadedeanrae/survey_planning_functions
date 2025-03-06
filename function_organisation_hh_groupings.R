
find_groupings <- function(data, 
                           distance = 1000,
                           path){
  
  data_sf <- st_as_sf(data, coords = c("longitude", "latitude"), crs = 4326)
  data_sf <- st_transform(data_sf,  "EPSG:32629")
  coords_matrix <- st_coordinates(data_sf)
  
  clusters <- dbscan(as.matrix(coords_matrix), eps = distance, minPts = 1)
  data$cluster <- as.factor(clusters$cluster)
  
  clusters <- ggplot(data, aes(x = longitude, y = latitude, color = as.numeric(cluster))) +
    geom_point(size = 1) +
    scale_color_viridis_c(option = "D") + 
    theme_minimal() +
    theme(legend.position = "none")
  
  print(clusters)
  
  write_csv(data, paste0(path, "sampled_buildings_clusters.csv"))
  
  return(data)
  
  }

