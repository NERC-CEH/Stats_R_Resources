library(shiny)

# Define UI 
ui <- fluidPage(
  
  # Application title
  titlePanel("Tabsets"),
  
  # Sidebar with controls 
  sidebarLayout(
    sidebarPanel(
      
      ## Add a file upload widget. Use the file
      ## 'example_03_data.csv' for testing
    
      ## Add some widgets to control your plot
      ## such as axis limits or point size/colour
      
      ),
    
    # Show a tabset that includes a plot, summary, and table view
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Plot", plotOutput("plot")), 
                  tabPanel("Summary", verbatimTextOutput("summary")), 
                  tabPanel("Table", DT::dataTableOutput("table"))
      )
    )
  )
)


server <- function(input, output) {
  
  ## Read in the csv specified by the user

  
  ## Generate a plot of the data.
  output$plot <- renderPlot({
    
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    
  })
  
  # Generate an HTML table view of the data
  output$table <- DT::renderDataTable({
    
  })
  
}

shinyApp(ui = ui, server = server)