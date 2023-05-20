CountyData_server <- function(id, CD, CGEO) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$apply_btn, {
      req(input$years_inp, input$states_inp, input$var_inp, input$n_bins)
      CGEO$get(
        CD$get(sort(input$years_inp), sort(input$states_inp)), 
        input$var_inp, 
        input$n_bins
      )
      # Triggering the filter
      trigger("filter")
    },
    ignoreInit = TRUE)
  })
}

debug_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$debug <- renderPrint("DEBUG")
  })
}

CountyGEO_server <- function(id, CGEO, var, n) {
  moduleServer(id, function(input, output, session) {
    output$chloropleth <- renderTmap({
      # Only plot when the filter is applied
      watch("filter")
      CGEO$chloropleth()
    })
  })
}


