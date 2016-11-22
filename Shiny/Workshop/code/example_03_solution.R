library(shiny)

# Define UI 
ui <- fluidPage(
  
  # Application title
  titlePanel("Tabsets"),
  
  # Sidebar with controls 
  sidebarLayout(
    sidebarPanel(
      fileInput('file1', 'Choose CSV File',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
    
      br(),
      
      sliderInput("factor", 
                  "Point size factor:", 
                  value = 2,
                  min = 0.5, 
                  max = 5.0,
                  step = 0.1),
      
      sliderInput("xrange", 
                  "x-axis range:", 
                  value = c(1, 27000),
                  min = 1, 
                  max = 27000)
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
  
  # Read in the csv specified by the user
  data <- reactive({
    
    inFile <- input$file1
    
    if (is.null(inFile)){
      return(NULL)
    }
    
    read.csv(inFile$datapath,
             header = TRUE)
    
  })
  
  # Generate a plot of the data.
  output$plot <- renderPlot({
    
    if(!is.null(data())){
      
    plot(x = data()[, 'Records'],
         xlab = 'Records',
         y = data()[, 'Species'],
         ylab = 'Species',
         cex = ((log(data()[, 'Observers'])/log(max(data()[, 'Observers']))) + 0.5) * input$factor,
         col = rgb(0, 0, 0, 0.1),
         pch = 20,
         xlim = input$xrange,
         ylim = range(data()[, 'Species']))
    
    } else {
      
      return(NULL)
      
    }
    
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    summary(data())
  })
  
  # Generate an HTML table view of the data
  output$table <- DT::renderDataTable({
    DT::datatable(data())
  })
  
}

shinyApp(ui = ui, server = server)