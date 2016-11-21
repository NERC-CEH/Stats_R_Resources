library(shiny)

ui <- fluidPage(
  # 1. Add a slider that allows your user 
  # to select a number between 1 and 100
  # set the initial value to 25
  # hint: look at 'sliderInput'
)

server <- function(input, output) {
  # 2a. Add a histogram that plots a 
  # randoms number with the number of numbers
  # set by your input slider
  # hint: look at function 'renderplot'
  # 2b. Add an output element to the ui (above)
  # to display your histogram
  # hint: 'plotOutput'
}

shinyApp(ui = ui, server = server)