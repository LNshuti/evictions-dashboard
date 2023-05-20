HashMapR6 <- R6::R6Class(
  "HashMapR6",
  public = list(
    #' @field hm an `r2r::hashmap()` object.
    hm = NULL,
    #' @field full the full, un-transformed object
    full = NULL,
    #' @field path path to the full object
    path = NULL,
    #' @field value_fns a function that takes the full un-transformed object
    #' and the key and transform it into one value.
    value_fns = NULL,

    #' @description
    #' Create a new HashMapR6 object.
    #' @return A new HashMapR6 object.
    initialize = function(path) {
      stopifnot("File doesn't exists" = file.exists(path))
      self$path <- path
      self$hm <- r2r::hashmap(on_missing_key = "throw")
    },

    #' @description
    #' Get the value from the hashmap with provided key. If provided key doesn't
    #' exist, then transform the self$full object and key into a value and store
    #' in the hashmap.
    #' @param key random R object.
    setdefault = function(key) {
      if (r2r::has_key(self$hm, key = key)) {
        message("fetching")
        return(self$hm[[key]])
      }
      message("caching")
      r2r::insert(self$hm, key = key, value = self$value_fns(key = key))
      return(self$hm[[key]])
    }
  )
)

CountyData <- R6::R6Class(
  "CountyData",
  inherit = HashMapR6,
  public = list(
    years = numeric(),
    states = character(),
    initialize = function(path = character()) {
      super$initialize(path)
      self$full <- fst::read_fst(self$path, as.data.table = TRUE)
      stopifnot(all(data.table::key(self$full) == c("year", "state_abbv", "county")))
      self$value_fns <- function(key) {
        query <- self$full[key, nomatch = NULL]
        if (nrow(query) == 0) {
          return(NULL)
        }
        return(query)
      }
      # choices
      self$years <- self$full[, sort(unique(year))]
      self$states <- self$full[, sort(unique(state_abbv))]
    },
    parse_years = function(years) {
      y <- as.numeric(years)
      stopifnot(!anyNA(y), y %in% self$years)
      return(y)
    },
    parse_states = function(states) {
      # Input needs to be sorted and typed so the key is unique
      stopifnot(is.character(states), length(states) > 0, !is.unsorted(states))
      if ("mainland" %in% states & length(states) == 1) {
        return(setdiff(self[["states"]], "HI"))
      }
      stopifnot(all(setdiff(states, "mainland") %in% self[["states"]]))
      return(setdiff(states, "mainland"))
    },
    get = function(years, states) {
      k <- list(
        self$parse_years(years),
        self$parse_states(states)
      )
      return(self$setdefault(k))
    }
  )
)

CountyGEO <- R6::R6Class(
  "CountyGEO",
  inherit = HashMapR6,
  public = list(
    bins = NULL,
    sf = NULL,
    query = NULL,
    # plot controls, suboptimal placement
    var = NULL,
    n = NULL,
    initialize = function(path = character()) {
      super$initialize(path)
      self$full <- sf::st_read(self$path)
      self$value_fns <- function(key) {
        self$query <- merge(self$full, key, by = "fips", all.y = TRUE)
        if (nrow(self$query) == 0) {
          return(NULL)
        }
        return(self$query)
      }
    },
    get = function(dt, var, n) {
      data.table::is.data.table(dt)
      stopifnot(var %in% names(dt))
      self$var <- var
      self$n <- n
      if (nrow(dt) == 0 | is.null(dt)) {
        return(NULL)
      }
      self$sf <- self$setdefault(dt)
      invisible(self)
    },
    chloropleth = function() {
      if (nrow(self$sf) == 0 | is.null(self$sf)) {
        return(NULL)
      }
      return({
        tmap::tm_shape(self$sf) +
          tmap::tm_polygons(self$var, palette = "RdYlBu", n = self$n, alpha = 0.75) +
          tmap::tm_facets(by = "year", ncol = 3, as.layers = FALSE)
      })
    }
  )
)

# If using mapview
# self$bins <- quantile(
#   dt[[var]],
#   probs = round(seq(from = 0, to = 1, length.out = n), 2),
#   na.rm = TRUE
# )
# map_l <- lapply(
#   dt[, sort(unique(year))],
#   \(x) {
#     return(mapview::mapview(
#       filter(self$sf, year == x),
#       layer.name = x,
#       zcol = var,
#       at = self$bins,
#       legend = TRUE
#     ))
#   }
# )
# return(map_l)
