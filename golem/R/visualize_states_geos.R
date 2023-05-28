library(ggrepel)
library(sf)
library(here)
library(tidyverse)

Sys.setenv(
  AWS_ACCESS_KEY_ID = my_access_key,
  AWS_SECRET_ACCESS_KEY = my_secret_key,
  AWS_REGION = my_region
)


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