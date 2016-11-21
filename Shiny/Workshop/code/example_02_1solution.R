# 1 - Add a drop down menu that allows the user to select the 
# y axis variable hint: look at the x axis for inspiration
# 2 - Add a text box that allows the user to set the 
# chart title. Hint: textInput
# 3 - Change the 'Number of clusters' selection to a slider
# and make it animate
# 4 - Add an interactive table of the dataset below the 
# current user interface. hint: http://shiny.rstudio.com/gallery/basic-datatable.html 

ui <- pageWithSidebar(
  headerPanel('Iris k-means clustering'),
  sidebarPanel(
    selectInput('xcol', 'X Variable', names(iris)),
    selectInput('ycol', 'Y Variable', names(iris),
                selected=names(iris)[[2]]),
    numericInput('clusters', 'Cluster count', 3,
                 min = 1, max = 9)
    ),
  mainPanel(
    plotOutput('plot1')
  )
)

server <- function(input, output, session) {
  
  # Combine the selected variables into a new data frame
  selectedData <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })
  
  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })
  
  output$plot1 <- renderPlot({
    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
              "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
    
    par(mar = c(5.1, 4.1, 2, 1))
    plot(selectedData(),
         col = clusters()$cluster,
         pch = 20, cex = 3)
    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
  })
  
}

shinyApp(ui = ui, server = server)