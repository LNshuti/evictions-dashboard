library(R6)
library(leaflet)

CountyData <- R6::R6Class(
  "CountyData",
  public = list(
    raw_dt = NULL,
    year = numeric(),
    years = numeric(),
    cache = list(),
    initialize = function(path = character()) {
      stopifnot("File input error" = file.exists(path))
      self$raw_dt <- fst::read_fst(path, as.data.table = TRUE)
      self$years <- self$raw_dt[, sort(unique(year))]
      self$set(self$raw_dt[, max(year)])
    },
    parse_year = function(year) {
      stopifnot("Select only one year" = length(year) == 1)
      if (is.character(year)) {
        self$year <- as.numeric(year)
      } else {
        self$year <- year
      }
      stopifnot("Invalid year input" = !anyNA(self$year))
      stopifnot("Selected year is not in the data" = self$year %in% self$years)
    },
    set = function(year) {
      self$parse_year(year)
      if (is.null(self$cache[[as.character(self$year)]])) {
        # message("Caching")
        self$cache[[as.character(self$year)]] <-
          copy(self$raw_dt[year == self$year,])
      }
      invisible(self)
    },
    get = function(year) {
      return(self$set(year)$cache[[as.character(self$year)]])
    }
  )
)

CountyGEO <- R6::R6Class(
  "CountyGEO",
  public = list(
    raw_shp = NULL,
    year = character(),
    cache = list(),
    joined_shp = NULL,
    viz_var = NULL,
    viz_choices = c("renting_hh", "filings_observed", "hh_threat_observed"),
    bins = NULL,
    pal = NULL,
    initialize = function(path = character()) {
      stopifnot("File input error" = file.exists(path))
      self$raw_shp <- sf::st_read(path)
    },
    set = function(dt) {
      stopifnot(data.table::is.data.table(dt))
      self$year <- dt[, as.character(unique(year))]
      if (is.null(self$cache[[self$year]])) {
        self$cache[[self$year]] <-
          merge(self$raw_shp, dt, by.x = "id", by.y = "fips_char")
      } 
      invisible(self)
    },
    get = function(dt) {
      return(self$set(dt)$cache[[self$year]])
    },
    set_joined_shp = function(dt) {
      self$joined_shp <- self$get(dt)
    },
    set_chloro_params <- function(v, cuts) {
      stopifnot(v %in% self$viz_choices)
      self$viz_var <- v
    },
    set_pal <- function(cuts) {
      self$bins <- cuts
      if(max(cuts) < max())
      stopifnot(all(range(cuts)))
      self$pal <- leaflet::colorBin("YlOrRd", domain = self$viz_var, bins = self$bins)
    }
    chloro = function(v, cuts, dt) {
      bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
      pal <- colorBin("YlOrRd", domain = d$renting_hh, bins = bins)
    }
  )
)
