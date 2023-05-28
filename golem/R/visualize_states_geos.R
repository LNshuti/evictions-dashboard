library(ggrepel)

# Load shape files
sf_state <- read_sf(here("output/state/01_state-shape-file.shp")) %>% 
  st_transform(crs = 4326) 