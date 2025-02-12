# / Household selection - simple random sampling

household_selection <- function(data, 
                                n_buildings,
                                district = NULL,
                                path,
                                assign_name){
  
  
  if(!is.null(district)){
    shapefile <- subset(shapefile, (ADM2_EN == district))
  }
  
  set.seed(123)
  
  #--- Random selection --- 
  sample <- data %>% 
    slice_sample(n = n_buildings)
  
  write_csv(sample, paste0(path, "sampled_buildings.csv"))
  
  ggplot() + 
    geom_sf(data = shapefile, fill = NA) +
    geom_sf(data = sample, color = "black", shape = 17, size = 5) + 
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
  
  assign(assign_name, sample, envir = .GlobalEnv)
  
}


