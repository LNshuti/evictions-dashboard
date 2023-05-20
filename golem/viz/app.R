library(shiny)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)
library(data.table) # Requires dev version of data.table
library(scales)
library(tmap)
library(purrr)
library(dplyr)
library(R6)
library(gargoyle)
options("gargoyle.talkative" = TRUE)

# file.edit(here::here("golem", "R", "CountyData_server.R"))

for (i in list.files(here::here("golem", "R"), full.names = TRUE)) {
  source(i)
  # file.edit(i)
}

chloroplethApp <- function() {
  CD <- CountyData$new(here::here("data", "temp", "county_court-issued_2000_2018.fst"))
  CGEO <- CountyGEO$new(here::here("data", "temp", "counties_geojson_sf.shp"))
  
  ui <- fluidPage(
    # Sidebar layout
    sidebarLayout(
      sidebarPanel(
        CountyData_ui(
          "CountyData_data",
          var_choice = setdiff(names(CD$full), c("year", "fips", "county", "state_abbv")),
          year_choice = CD$years,
          state_choice = c("mainland", CD$states)
        )
      ),
      mainPanel(
        CountyData_plot("CD_tmap")
        #, debug_out("debug")
      )
    )
  )

  server <- function(input, output, session) {
    init("filter")
    CountyData_server("CountyData_data", CD = CD, CGEO = CGEO)
    # debug_server("debug")
    CountyGEO_server("CD_tmap", CGEO = CGEO)
  }
  
  shinyApp(ui = ui, server = server)
}

chloroplethApp()
