#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)
library(shinythemes)
# Define UI for the application
ui <- fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("Evictions Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("state", "State:",
                  choices = unique(evictions_data$state)),
      selectInput("county", "County:",
                  choices = unique(evictions_data$county))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Evictions Histogram", plotOutput("distPlot")),
        tabPanel("Median Income Map", leafletOutput("mapPlot"))
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Filter data based on state and county selections
  filtered_data <- reactive({
    evictions_data %>%
      filter(state == input$state, county == input$county)
  })
  
  # Update county options based on the selected state
  observeEvent(input$state, {
    updateSelectInput(session, "county", 
                      choices = unique(evictions_data$county[evictions_data$state == input$state]))
  })
  
  # Render the histogram of evictions
  output$distPlot <- renderPlot({
    ggplot(filtered_data(), aes(x = evictions)) +
      geom_histogram(bins = 30, fill = "darkgray", color = "white") +
      labs(title = "Histogram of Evictions",
           x = "Evictions",
           y = "Frequency") +
      theme_minimal()
  })
  
  # Render the median income map
  output$mapPlot <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addCircles(lng = ~longitude, lat = ~latitude, data = filtered_data(),
                 radius = ~median_income/100, 
                 fillColor = "blue", stroke = FALSE, fillOpacity = 0.4) %>%
      addLegend("bottomright", colors = "blue", 
                labels = "Median Income by Zipcode", 
                opacity = 0.4, title = "Median Income")
  })
}

# Load the latest evictions data (replace with the appropriate data source)
evictions_data <-
  read.csv("/data/county_court-issued_2000_2018.csv")

# Run the Shiny application
shinyApp(ui = ui, server = server)
