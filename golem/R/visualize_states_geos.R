library(ggrepel)
library(sf)
library(here)
library(tidyverse)

# Retrieve the environment variable keys
my_access_key <- Sys.getenv("AWS_ACCESS_KEY_ID")
my_secret_key <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
my_token <- Sys.getenv("MY_TOKEN")
my_region <- Sys.getenv("AWS_REGION")

# Connect to S3 using temporary security credentials.
s3_other <- paws::s3(
  config = list(
    credentials = list(
      creds = list(
        access_key_id = my_access_key,
        secret_access_key = my_secret_key,
        session_token = my_token
      )
    ),
    region = my_region
  )
)

# Load shape files
sf_state <- read_sf(here("golem/R/output/state/01_state-shape-file.shp")) %>% 
  st_transform(crs = 4326) 

library(maps)
usa <- st_as_sf(map('usa', plot = FALSE, fill = TRUE))
laea <- st_crs("+proj=laea +lat_0=30 +lon_0=-95") # Lambert equal area
usa <- st_transform(usa, laea)
g <- st_graticule(usa)
plot(st_geometry(g), axes = TRUE, bg = "lightblue") # Set the background color to light ocean blue
g <- st_graticule(usa, lon = seq(-130, -65, 5))
plot(usa, graticule = g, key.pos = NULL, axes = TRUE,
     xlim = st_bbox(usa)[c(1, 3)], ylim = st_bbox(usa)[c(2, 4)],
     xaxs = "i", yaxs = "i")

# Add the Nashville Entrepreneur Centre location
nashville_loc <- data.frame(
  Location = "Nashville Entrepreneur Centre",
  Lon = -86.7816, # Longitude of Nashville
  Lat = 36.1627   # Latitude of Nashville
)
nashville_sf <- st_as_sf(nashville_loc, coords = c("Lon", "Lat"), crs = 4326)
nashville_sf <- st_transform(nashville_sf, laea)
plot(nashville_sf, pch = 20, col = "red", add = TRUE) # Plot the location on the map


# Connect to the database.
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "myhost", port = 5432, dbname = "mydb",
  user = "david", password = password
)

# Create a reference to the table, query the database, and download the result.
my_table <- table(con, "my_table")
result <- my_table %>%
  filter(record_type == "ok")
collect()


# Connect to the database using an IAM authentication token.
rds <- paws::rds()
token <- rds$build_auth_token(endpoint, region, user)
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "myhost", port = 5432, dbname = "mydb",
  user = "david", password = token
)