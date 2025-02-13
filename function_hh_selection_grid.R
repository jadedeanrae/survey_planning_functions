# Sampling over grided area 

grid_household_selection <- function(data,
                                     cell_size,
                                     target,
                                     n_buildings,
                                     path, 
                                     assign_total_buildings, 
                                     assign_selected_buildings
                                     ){
  
  # Limit to sub area (e.g. rural area)
  shapefile_filtered <- st_difference(shapefile, st_union(buffer_polygons))
  buildings_filtered <- st_difference(data, st_union(buffer_polygons))
  
  # Create the grid
  grid <- st_make_grid(shapefile_filtered, 
                       cellsize = c(cell_size, cell_size), 
                       square = TRUE) %>% 
    st_as_sf() %>% 
    mutate(cell_id = row_number())
  
  # Take centroid for each household
  centroids <- st_centroid(buildings_filtered)
  centroids_sf <- st_sf(centroids)
  
  # Assign buildings to grids 
  grid_contained <- st_intersection(grid, centroids_sf)
  points_within_grid <- st_join(centroids_sf, grid, join = st_within)
  
  # Number of buildings by grid 
  grid_counts <- points_within_grid %>%
    group_by(cell_id) %>%
    summarise(count = n()) 
  
  grid_with_counts <- st_join(grid, grid_counts, left = TRUE) %>%
    mutate(count = replace_na(count, 0))
  
  # Keep grids with buildings
  grid_with_counts_yes <- grid_with_counts %>%
    filter(count > 0) %>%
    dplyr::select(-c(cell_id.x)) %>%
    rename(
      cell_id = cell_id.y)
  
  ggplot() + 
    geom_sf(data = grid_with_counts_yes, fill = NA) +
    geom_sf(data = shapefile_filtered)
  
  # Intersection between grid and sub area (e.g. remove urban areas)
  grid_subarea <- st_intersection(grid_with_counts_yes, shapefile_filtered)
  
  ggplot() + 
    geom_sf(data = shapefile_filtered, fill = NA) +
    geom_sf(data = grid_subarea, fill = NA)
  
  # Average household number per grid 
  grid_subarea.df <- as.data.frame(grid_subarea)
  
  grid_subarea.df %>%
    summarise(
      median_hh = median(count, na.rm = TRUE),
      average_hh = mean(count, na.rm = TRUE))
  
  #--- Sampling weights for grid cells (PPS - probability proportion to size) --- 
  grid_subarea$weight <- (grid_subarea$count /  sum(grid_subarea$count)) * 100
  
  #--- Sample grid cells ---
  grid_subarea <- grid_subarea %>% 
    mutate(
      max_sample = ifelse(count > n_buildings, n_buildings, count))
  
  set.seed(123)
  sampled_grids <- c()
  total_buildings <- 0 
  
  while(total_buildings <= target){
    
    sampled_grid <- sample(grid_subarea$cell_id, size = 1, replace = FALSE, prob = grid_subarea$weight)
    
    if (!(sampled_grid %in% sampled_grids)) { 
      sampled_grids <- c(sampled_grids, sampled_grid)
      
      selected_grid_subarea <- grid_subarea %>% filter(cell_id %in% sampled_grids)  
      
      total_buildings <- sum(selected_grid_subarea$max_sample) 
    }
  }
  
  write_csv(selected_grid_subarea, paste0(path, "grids_selected.csv"))
  
  ggplot() +
    geom_sf(data = shapefile, fill = NA) +
    geom_sf(data = grid_subarea, fill = "grey90") +
    geom_sf(data = selected_grid_subarea, fill = "black") +
    theme_bw() +
    theme(axis.text = element_blank(),
          axis.ticks = element_blank(),
          panel.border = element_blank(),
          panel.grid = element_blank()) +
    annotation_scale(location = "br",
                     style="ticks",
                     width_hint = 0.2) +
    annotation_north_arrow(location = "br",
                           pad_x = unit(0, "in"), pad_y = unit(0.3, "in"),
                           which_north = "true",
                           style = north_arrow_fancy_orienteering)
  
  ggsave(paste0(path, "selected_grids.png"), dpi = 300, height = 6, width = 6)
  
  #--- Random selection in selected grids ---
  subarea_buildings <- st_intersection(selected_grid_subarea, centroids_sf)
  
  # Sample buildings
  set.seed(123)
  
  sample_subarea <- subarea_buildings %>%
    group_by(cell_id) %>%
    slice_sample(n = n_buildings)
  
  sample_plot <- ggplot() +
    geom_sf(data = shapefile, fill = NA) +
    geom_sf(data = selected_grid_subarea) +
    geom_sf(data = sample_subarea, size = 0.5) +
    theme_bw() +
    theme(axis.text = element_blank(),
          axis.ticks = element_blank(),
          panel.border = element_blank(),
          panel.grid = element_blank()) +
    annotation_scale(location = "br",
                     style="ticks",
                     width_hint = 0.2) +
    annotation_north_arrow(location = "br",
                           pad_x = unit(0, "in"), pad_y = unit(0.3, "in"),
                           which_north = "true",
                           style = north_arrow_fancy_orienteering)
  
  ggsave(paste0(path, "sampled_buildings.png"), dpi = 300, height = 6, width = 6)
  
  sample_subarea_df <- as.data.frame(sample_subarea)
  
  write_csv(sample_subarea_df, paste0(path, "sampled_buildings.csv"))
  
  assign(assign_total_buildings, subarea_buildings, envir = .GlobalEnv)
  assign(assign_selected_buildings, sample_subarea, envir = .GlobalEnv)
  
  return(sample_plot)
  
}
