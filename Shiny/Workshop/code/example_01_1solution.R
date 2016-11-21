library(shiny)

ui <- fluidPage(
  # 1. Add a slider that allows your user 
  # to select a number between 1 and 100
  # set the initial value to 25
  # hint: look at 'sliderInput'
  sliderInput(inputId = "num", 
              label = "Choose a number", 
              value = 25, min = 1, max = 100)
)

server <- function(input, output) {

  }

shinyApp(ui = ui, server = server)