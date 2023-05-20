CountyData_ui <- function(id, var_choice, year_choice, state_choice) {
  ns <- NS(id)
  tagList(
    pickerInput(
      inputId = ns("years_inp"),
      label = "Years",
      choices = year_choice,
      selected = 2018,
      options = list(
        `live-search` = TRUE,
        `actions-box` = TRUE,
        `selected-text-format` = "count > 3"
      ),
      multiple = TRUE
    ),
    pickerInput(
      inputId = ns("states_inp"),
      label = "States",
      choices = state_choice,
      selected = "mainland",
      options = list(
        `live-search` = TRUE,
        `actions-box` = TRUE,
        `selected-text-format` = "count > 3"
      ),
      multiple = TRUE
    ),
    numericInput(
      inputId = ns("n_bins"),
      label = "N category of colors",
      value = 10,
      min = 2,
      max = 50,
      step = 1
    ),
    pickerInput(
      inputId = ns("var_inp"),
      label = "Variable to Visualize",
      choices = var_choice,
      selected = var_choice[1]
    ),
    actionBttn(
      inputId = ns("apply_btn"),
      label = "Apply",
      style = "pill",
      color = "success"
    )
  )
}

debug_out <- function(id) {
  ns <- NS(id)
  tagList(
    verbatimTextOutput(ns("debug"))
  )
}

CountyData_plot <- function(id) {
  ns <- NS(id)
  tagList(
    tmapOutput(ns("chloropleth"))
  )
}
