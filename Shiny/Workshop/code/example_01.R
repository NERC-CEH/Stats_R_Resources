library(shiny)

ui <- fluidPage(
  # 1. Change the slider so it can only select a number
  # between 1 and 500. Set the starting value to 200
  sliderInput(inputId = "num", 
              label = "Choose a number", 
              value = 500, min = 10, max = 1000)
  # 2. Add an output element to display your histogram
  # hint: 'plotOutput'
)

server <- function(input, output) {
  output$hist <- renderPlot({
    hist(rnorm(input$num))
  })
}

shinyApp(ui = ui, server = server)