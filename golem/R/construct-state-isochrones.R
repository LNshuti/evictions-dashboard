
# For each state, iterate through all the countys. For each county, create and save a list of 8 dataframes to AWS.
# Each dataframe in this list will contain the geographic coordinates for a given travel time from the given county
# in a given state. 


# Load required libraries and helper functions
source(here::here("golem/R/manifest.R"))
source(here::here("golem/R/shared-objects.R"))

# Load shape file for counties
sfcounty <- read_sf(here("golem/output/tidy-mapping-files/county/01_county-shape-file.shp")) %>%
  st_transform(crs = 4326)

# Create folder on the AWS bucket where we store isochrones data
# put_folder(folder = "isochrones-data/", bucket = "health-care-markets")

# configure the future_map looping function to use multiple cores for fast processing
plan(multicore)

# Extending the api request for multiple zips at once
# Sample 100 of the 30000+ zips and use mapbox to find
# isochrones for 15, 30, 45, and 60 minutes drive time.
zip_centroids <- sfcounty %>% st_centroid()

# Get the X,Y coordinates of the centroids (bind as extra columns)
zip_centroids_coords <-
  bind_cols(zip_centroids, zip_centroids %>% st_coordinates() %>% as_tibble() %>% set_names(c("x", "y"))) %>%
  ungroup() %>%
  data.frame() %>%
  as_tibble()


# Given the limitation that we cannot go over 60 minutes isochrones
#  These are all the possible travel times that we can use:
required_travel_times <- list(c("10, 15, 20, 30"), c("40, 45, 50, 60"))
states_output <- list()
# Create objects by state for the first 10 states
for (state in c("IN", "IA")) {
  
  # Create an iterable object by state, with longitude and latitudes
  st_zip_centroids_coords <-
    zip_centroids_coords %>%
    filter(state == state) %>%
    filter(!is.na(x))
  
  # For a given zip in a given state, obtain isochrones for 10,15, 20, and 30 minutes driving times
  travel_time_15_30 <-
    st_zip_centroids_coords %>%
    mutate(test = future_map2(x, y, ~ (c(.x, .y)))) %>%
    pull(test) %>%
    future_map(~ (get_mapbox_isochrone(long = .x[1], lat = .x[2], contours_minutes = "10, 15, 20, 30")), .progress = TRUE) %>%
    set_names(st_zip_centroids_coords$zip_code)
  
  # For a given zip in a given state, obtain isochrones for 40, 45, 50, and 60 minutes driving times
  travel_time_40_60 <-
    st_zip_centroids_coords %>%
    mutate(test = future_map2(x, y, ~ (c(.x, .y)))) %>%
    pull(test) %>%
    future_map(~ (get_mapbox_isochrone(long = .x[1], lat = .x[2], contours_minutes = "40, 45, 50, 60")), .progress = TRUE) %>%
    set_names(st_zip_centroids_coords$zip_code)
  
  # Merge the travel times isochrones into one list object
  all_travel_times <- mapply(c, travel_time_15_30, travel_time_40_60, SIMPLIFY = FALSE)
  
  file_name_st <- paste0(state, "-zip-isochrones.Rdata")
  print(file_name_st)
  
  print(all_travel_times)
  #s3save(all_travel_times, bucket = "health-care-markets", object = paste0("isochrones-data/state/", file_name_st))
  
  Sys.sleep(6)
}