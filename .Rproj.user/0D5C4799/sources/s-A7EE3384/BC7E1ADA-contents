# plot module ----
plot_ui <- function(id) {
  
  fluidRow(
    column(11, plotOutput(NS(id, "plot"))),
    column( 1, downloadButton(NS(id, "dnld"), label = ""))
  )
  
}

plot_server <- function(id, mydf, vbl, threshhold = NULL) {
  
  moduleServer(id, function(input, output, session) {
    
    plot <- reactive({viz_output(mydf(), vbl, threshhold)})
    output$plot <- renderPlot({plot()})
    output$dnld <- downloadHandler(
      filename = function() {paste0(vbl, '.png')},
      content = function(file) {ggsave(file, plot())}
    )
    
  })
}

plot_demo <- function() {
  
  mydf <-  c1 %>% filter(doseid == 1 & cohort_n == 1)
  ui <- fluidPage(plot_ui("x"))
  server <- function(input, output, session) {
    plot_server("x", reactive({mydf}), "TargetEng")
  }
  shinyApp(ui, server)
  
}