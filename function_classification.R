# // Uurban/rural classification

urban_rural_classification <- function(buildings
                                       ){
  
  #--- Calculate building density ---
  grid <- st_make_grid(buildings, 
                       cellsize = c(cell_size, cell_size), 
                       square = TRUE) %>% 
    st_as_sf() %>% 
    mutate(cell_id = row_number())
  
  # Take centroid for each household
  centroids <- st_centroid(buildings)
  centroids_sf <- st_sf(centroids)
  
  # Number of points within grid cells
  points_within_grid <- st_join(centroids_sf, grid, join = st_within)
  
  grid_counts <- points_within_grid %>%
    group_by(cell_id) %>%
    summarise(count = n()) 
  
  # Keep only grid cells with buildings
  grid_with_counts <- st_join(grid, grid_counts, left = TRUE) %>%
    mutate(count = replace_na(count, 0))
  
  write_sf(grid_with_counts, paste0("output/urban classification/building_density_", cell_size, "m.shp"))
  
  grid_with_counts_yes <- grid_with_counts %>% 
    filter(count > 0)
  
  # Plot density
  ggplot() + 
    geom_sf(data = grid_with_counts_yes, aes(fill = count)) + 
    theme_bw() + 
    labs(fill = bquote("Number of\nbuildings per " * .(cell_size) * " m²"))
  
  ggsave(paste0("output/urban classification/buildings_per_", cell_size, "m.png"), dpi = 300)
  
  # Keep grids with enough buildings
  grid_with_counts_yes <- grid_with_counts %>% 
    filter(count > buildings_per_grid)
  
  #--- Identify areas with high building density ---
  building_extent <- st_bbox(grid_with_counts_yes)
  
  raster_template <- rast(extent = ext(building_extent),
                          resolution = cell_size,
                          crs = "EPSG:32629")
  
  # Extract bounding box components
  bbox <- st_bbox(grid_with_counts_yes)
  raster_template <- raster(xmn = bbox["xmin"], 
                            xmx = bbox["xmax"], 
                            ymn = bbox["ymin"], 
                            ymx = bbox["ymax"], 
                            resolution = c(cell_size, cell_size)) 
  
  # Set the CRS of the raster to match the shapefile
  crs(raster_template) <- st_crs(grid_with_counts_yes)$proj4string
  
  # Create the density raster
  density_raster <- rasterize(grid_with_counts_yes, 
                              raster_template, 
                              field = "count", 
                              fun = sum)
  
  #--- Identify urban areas ---
  clumped_urban <- clump(density_raster, direction = 8)
  
  clump_sums <- zonal(density_raster, clumped_urban, fun = sum, na.rm = TRUE)
  
  # Convert the 'value' column (second column) to numeric
  values_numeric <- as.numeric(clump_sums[, 2])
  
  zone_list <- clump_sums[values_numeric > buildings_per_clump, 1]
  
  # Convert the clumped raster to polygons
  clumped_polygons <- rasterToPolygons(clumped_urban, dissolve = TRUE)
  
  # Extract the clump ID for clumps where the total population exceeds thesehold for urban class
  selected_polygons <- clumped_polygons[clumped_polygons$clumps %in% zone_list, ]
  
  # Convert to shapefile
  selected_polygons_sf <- st_as_sf(selected_polygons)
  
  gee_clumps <- ggplot() + 
    geom_sf(data = shapefile, fill = NA) +
    geom_sf(data = gee_buildings, color = "black") +
    geom_sf(data = selected_polygons_sf, aes(fill = as.factor(clumps))) +
    labs(fill = "Urban") + 
    theme_bw() +
    coord_sf() + 
    theme(axis.title = element_blank(), 
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          panel.grid = element_blank(), 
          panel.border = element_blank(), 
          legend.position = "right") + 
    annotation_scale(location = "br", 
                     style="ticks", 
                     width_hint = 0.2) + 
    annotation_north_arrow(location = "br", 
                           pad_x = unit(0, "in"), pad_y = unit(0.3, "in"),
                           which_north = "true",  
                           style = north_arrow_fancy_orienteering) 
  
  ggsave("output/urban classification/gee_clumps.png", dpi = 500)
  
  # Create buffer around polygons
  buffer_polygons <- st_buffer(selected_polygons_sf, 250)
  
  gee_clumps <- ggplot() + 
    geom_sf(data = shapefile, fill = NA) +
    geom_sf(data = gee_buildings, color = "black") +
    geom_sf(data = buffer_polygons, aes(fill = as.factor(clumps))) +
    labs(fill = "Urban") + 
    theme_bw() +
    coord_sf() + 
    theme(axis.title = element_blank(), 
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          panel.grid = element_blank(), 
          panel.border = element_blank(), 
          legend.position = "none") + 
    annotation_scale(location = "br", 
                     style="ticks", 
                     width_hint = 0.2) + 
    annotation_north_arrow(location = "br", 
                           pad_x = unit(0, "in"), pad_y = unit(0.3, "in"),
                           which_north = "true",  
                           style = north_arrow_fancy_orienteering) 
  
  
  write_sf(buffer_polygons, paste0("output/urban classification/shapefiles/gee_clumps_buffer.shp"))
  ggsave("output/urban classification/gee_clumps_buffer.png", dpi = 500, height = 5, width = 7)
  
  # Number of buildings in clumps v. no-clump
  buildings_clumps <- st_join(buildings, buffer_polygons, join = st_within)
  buildings_clumps$location <- ifelse(!is.na(buildings_clumps$clumps), "Urban", "Rural")
  
  buildings_clumps_df <- as.data.frame(buildings_clumps)
  
  sum <- buildings_clumps_df %>% 
    group_by(location) %>% 
    summarise(total_buildings = n(),
              percent = round(total_buildings / nrow(buildings) * 100, 2))
  
  write_sf(buildings_clumps, paste0("output/urban classification/shapefiles/gee_clumps.shp"))
  
  write_csv(sum, "output/urban classification/gee_clumps_buffer_size.csv")
  
  assign("buildings_clumps", buildings_clumps, envir = .GlobalEnv)
  assign("buffer_polygons", buffer_polygons, envir = .GlobalEnv)

}
