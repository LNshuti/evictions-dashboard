#' ---
#' output: github_document
#' ---
suppressWarnings(suppressMessages(source(here::here("golem/R/manifest.R"))))
library(gganimate)
library(magick)
source(here("golem/R/map-theme.R"))
source(here("golem/R/shared-objects.R"))

# Load States Shapefiles for the US
sf_state <- read_sf(here("golem/output/tidy-mapping-files/state/01_state-shape-file.shp")) %>% 
  st_transform(crs = 4326)

sf_county <- read_sf(here("golem/output/tidy-mapping-files/county/01_county-shape-file.shp")) %>% 
  st_transform(crs = 4326)

sf_hsa <- read_sf(here("golem/output/tidy-mapping-files/hsa/01_hsa-shape-file.shp")) %>% 
  st_transform(crs = 4326)

sf_hrrs <- read_sf(here("golem/output/tidy-mapping-files/hrr/01_hrr-shape-file.shp")) %>% 
  st_transform(crs = 4326)


# Plot Tennessee state
ggplot() +
  geom_sf(data = sf_state %>% filter(stusps == "TN"), alpha = 0,lwd=.7,colour = "black") + 
  coord_sf(datum=NA) + 
  remove_all_axes +
  ggthemes::theme_tufte(base_family = "Gill Sans") 

# Plot Tennessee Counties 
ggplot() +
  geom_sf(data = sf_county %>% filter(state == "TN"), alpha = 0,lwd=.7,colour = "black") + 
  coord_sf(datum=NA) + 
  remove_all_axes +
  ggthemes::theme_tufte(base_family = "Gill Sans")

# Plot Tennessee HSAs 
ggplot() +
  geom_sf(data = sf_hsa %>% filter(hsastate == "TN"), alpha = 0,lwd=.7,colour = "black") + 
  coord_sf(datum=NA) + 
  remove_all_axes +
  ggthemes::theme_tufte(base_family = "Gill Sans") 

# Plot Tennessee HRRs 
ggplot() +
  geom_sf(data = sf_hrrs %>% filter(hrrstate == "TN"), alpha = 0,lwd=.7,colour = "black") + 
  coord_sf(datum=NA) + 
  remove_all_axes +
  ggthemes::theme_tufte(base_family = "Gill Sans") 