# Replacements for hh selection

replacement_selection <- function(data, 
                                  sample, 
                                  district = NULL, 
                                  max_distance = 30, 
                                  n_nearby = 2,
                                  path,
                                  assign_name
                                  ){
  
  #--- Reform data --- 
  # remaining_builds <- data[!apply(st_equals(data, sample, sparse = FALSE), 1, any), ]
  remaining_builds <- anti_join(data, sample, by = "id")
  rem_builds <- as.data.frame(remaining_builds)
  rem_builds_coords <- dplyr::select(rem_builds, c("longitude", "latitude"))
  sample_coords <- as.data.frame(sample)
  sample_coords <- dplyr::select(sample_coords, c("longitude", "latitude"))
  
  #--- Find points within distance from sample --- 
  distances_list <- list()
  
  for(i in 1:nrow(sample_coords)){
    
    distances <- distm(sample_coords[i, ],  
                       rem_builds_coords)
    nearby_points <- rem_builds_coords[distances <= max_distance, ] 
    distances_list[[i]] <- nearby_points
  }
  
  names(distances_list) <- sample$id
  
  #--- Random selection from nearby points --- 
  nearby_list <- list()
  
  for(i in 1:length(distances_list)){
    
    nearby_hh <- distances_list[[i]]
    
    if(nrow(nearby_hh) <= n_nearby) {nearby_list[[i]] <- nearby_hh
    } else {
      set.seed(0)
      selection_nearby <- nearby_hh[sample(nrow(nearby_hh), n_nearby, replace = FALSE), ]
      nearby_list[[i]] <- selection_nearby
    }
  }
  
  names(nearby_list) <- sample$id
  
  #--- Label points --- 
  for(i in 1:length(nearby_list)){
    
    if(nrow(nearby_list[[i]]) > 0){
      nearby_list[[i]]$id <- names(nearby_list[i])
    }
    
    if(nrow(nearby_list[[i]]) == 2){
      options <- c("a", "b")
      nearby_list[[i]]$id <- as.factor(paste(nearby_list[[i]]$id, options, sep="."))
    }
    
    if(nrow(nearby_list[[i]]) == 1){
      nearby_list[[i]]$id <- as.factor(paste(nearby_list[[i]]$id, "a", sep="."))
    }
  }  
  
  replacement_list <- do.call(rbind, lapply(nearby_list, function(x) x))  # Remove the 'level' column for combining
  replacement_list <- as.data.frame(replacement_list)
  
  assign(assign_name, replacement_list, envir = .GlobalEnv)
  
  write_csv(replacement_list, paste0(path, assign_name, ".csv"))
  
}

