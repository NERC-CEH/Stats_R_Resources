library(shiny)

ui <- fluidPage(
  # 1. Add a slider that allows your user 
  # to select a number between 10 and 1000
  # set the initial value to 500
  # hint: look at 'sliderInput'
  sliderInput(inputId = "num", 
              label = "Choose a number", 
              value = 500, min = 10, max = 1000)
)

server <- function(input, output) {

  }

shinyApp(ui = ui, server = server)