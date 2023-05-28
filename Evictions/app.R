#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(shiny.blueprint)

shinyApp(
  ui = tagList(
    Switch.shinyInput(
      inputId = "animate",
      value = TRUE,
      label = "Animate"
    ),
    reactOutput("progress")
  ),
  server = function(input, output) {
    output$progress <- renderReact({
      ProgressBar(animate = input$animate)
    })
  }
)