library(ggrepel)
library(sf)
library(here)
library(tidyverse)

# Load shape files
sf_state <- read_sf(here("golem/R/output/state/01_state-shape-file.shp")) %>% 
  st_transform(crs = 4326) 