library(shiny)

ui <- fluidPage(
  # 1. Add a slider that allows your user 
  # to select a number between 10 and 1000
  # set the initial value to 500
  # hint: look at 'sliderInput'
  sliderInput(inputId = "num", 
              label = "Choose a number", 
              value = 500, min = 10, max = 1000),
  plotOutput("hist")
)

server <- function(input, output) {
  # 2a. Add a histogram that plots a 
  # randoms number with the number of numbers
  # set by your input slider
  # hint: look at function 'renderplot'
  # 2b. Add an output element to the ui (above)
  # to display your histogram
  # hint: 'plotOutput'
  output$hist <- renderPlot({
    hist(rnorm(input$num))
  })
}

shinyApp(ui = ui, server = server)