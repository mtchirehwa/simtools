# Author: Maxwell Chirehwa
# Date Created: 05-July-2022
# Date Modified: XXXX
# Description: Shiny server for TMDD model simulator

# User functions
source('utils/global.R')

list.of.packages <-
  c('base', "survival", 'mstate', 'diagram', "shiny", 'shinyjs',
    'colourpicker', 'xtable',  'shinyBS', 'mrgsolve', 'shinydashboard', 'shinycssloaders', 'plotly', 'shinydashboardPlus', 'DT', 'tibble')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')

library(dplyr)
library(shiny)
library(survival)
library(shinyjs)
library(mstate)
library(colourpicker)
library(xtable)
library(diagram)
library(shinyBS)
library(mrgsolve)
library(shinydashboard)
library(shinycssloaders)
library(plotly)
library(markdown)
library(DT)
#library(shinydashboardPlus)
library(DT)
library(tibble)
library(purrr)

mod_qe <- mread_cache("analyses/TMDD_QE_2cmt_pop")
mod_full <- mread_cache("analyses/Full_TMDD_2cmt_pop")

shinyServer(function(input, output, session){
  print("Initialize Start")
  
  # Add input to dataframe
  ## Init with some example data
  data <- reactiveValues()
  
  data$pkteparams <- tibble(TVCL = numeric(),
                     TVV1 = numeric(),
                     TVQ1 = numeric(),
                     TVV2 = numeric(),
                     TVKA = numeric(),
                     TVF1 = numeric(),
                     TVBASE = numeric(),
                     TVKDEG = numeric(),
                     TVKINT = numeric(),
                     TVKD = numeric(),
                     MWmAb = numeric(),
                     MWtarget = numeric(),
                     Dose = numeric(),
                     II = numeric(),
                     ADDL = numeric(),
                     Sim_start = numeric(),
                     Sim_stop = numeric(),
                     Sim_step = numeric()
  )
  
  observeEvent(
    input$add_btn,
    {
      #start with current data
      tmp_pkteparams <-  tibble(
          `TVCL` = isolate(input$TVCL),
          TVV1 = isolate(input$TVV1),
          `TVQ1` = isolate(input$TVQ1),
          `TVV2` = isolate(input$TVV2),
          `TVKA` = isolate(input$TVKA),
          TVF1 = isolate(input$TVF1),
          TVBASE = isolate(input$TVBASE),
          TVKDEG = isolate(input$TVKDEG),
          TVKINT = isolate(input$TVKINT),
          TVKD = isolate(input$TVKD),
          MWmAb = isolate(input$MWmAb),
          MWtarget = isolate(input$MWtarget),
          Dose = isolate(input$Dose),
          II = isolate(input$II),
          ADDL = isolate(input$ADDL),
          Sim_start = isolate(input$Sim_start),
          Sim_stop = isolate(input$Sim_stop),
          Sim_step = isolate(input$Sim_step)
        )
        # update data value
      data$pkteparams <- data$pkteparams %>%  bind_rows(tmp_pkteparams)

    }
  )
  
  # Updating ui for scenarios when a datatable row is selected
  shiny::observe({
    if (!is.null(input$TBL1_rows_selected)) {
      "remember the row selected"
      row_sel <- input$TBL1_rows_selected
      mydata <- data$pkteparams[row_sel, ]
    shiny::updateNumericInput(session, "TVCL",  value = mydata$TVCL)
    shiny::updateNumericInput(session, "TVV1",  value = mydata$TVV1)
    shiny::updateNumericInput(session, "TVQ1",  value = mydata$TVQ1)
    shiny::updateNumericInput(session, "TVV2",  value = mydata$TVV2)
    shiny::updateNumericInput(session, "TVKA",  value = mydata$TVKA)
    shiny::updateNumericInput(session, "TVF1",  value = mydata$TVF1)
    shiny::updateNumericInput(session, "TVBASE",  value = mydata$TVBASE)
    shiny::updateNumericInput(session, "TVKDEG",  value = mydata$TVKDEG)
    shiny::updateNumericInput(session, "TVKINT",  value = mydata$TVKINT)
    shiny::updateNumericInput(session, "TVKD",  value = mydata$TVKD)
    shiny::updateNumericInput(session, "MWmAb",  value = mydata$MWmAb)
    shiny::updateNumericInput(session, "MWtarget",  value = mydata$MWtarget)
    shiny::updateNumericInput(session, "Dose",  value = mydata$Dose)
    shiny::updateNumericInput(session, "II",  value = mydata$II)
    shiny::updateNumericInput(session, "ADDL",  value = mydata$ADDL)
    shiny::updateNumericInput(session, "Sim_start",  value = mydata$Sim_start)
    shiny::updateNumericInput(session, "Sim_stop",  value = mydata$Sim_stop)
    shiny::updateNumericInput(session, "Sim_step",  value = mydata$Sim_step)
    }
  })
  
  # deleting a input design
  observeEvent(input$deletePressed, {
    rowNum <- parseDeleteEvent(input$deletePressed)
    # Delete the row from the data frame
    data$pkteparams <- data$pkteparams[-rowNum,]
  })
  
  # editing a record
  observeEvent(input$edit_btn,{
    
    if (!is.null(input$TBL1_rows_selected)) {
      cols_to_edit <- names(data$pkteparams)
      colnms <- names(data$pkteparams)
      "remember the row selected"
     data$row_selected <- input$TBL1_rows_selected
      
      walk2(cols_to_edit, colnms, ~{data$pkteparams[input$TBL1_rows_selected, ..2] <<- input[[..1]]}) 
      
    }
    
  })
  
  # run simulation
  observeEvent(
    input$run_simulation, {
      data$simout <- do.call(rbind, 
                        lapply(1:nrow(data$pkteparams), 
                               function(x){
                                 tempdata <- data$pkteparams[x,] %>% 
                                   mutate(ID = 1) %>% 
                                   rename(amt = Dose,
                                          ii = II,
                                          addl = ADDL)
                                 mod_qe %>% 
                                   idata_set(tempdata) %>% 
                                   ev(amt=tempdata$amt,
                                      ii = tempdata$ii,
                                      addl = tempdata$addl) %>% 
                                   mrgsim(end = tempdata$Sim_stop,
                                          delta = tempdata$Sim_step, 
                                          start = tempdata$Sim_start,
                                          obsonly = T) %>% 
                                   as_tibble() %>% 
                                   mutate(GROUP = x)
                               }))
      showNotification("Simulation step completed!!", closeButton = TRUE, type = 'message')
    }
  )
    
  

  output$TBL1 <- renderDataTable(
    # Add the delete button column
    deleteButtonColumn(data$pkteparams , 'delete_button')

  )
  
  output$simdata <- renderDataTable({
    datatable(head(data$simout),options = list(paging = FALSE))
    }
  )
  
  observeEvent(
    input$run_simulation, {
  output$summary_mAb <- renderDataTable({
    data$simout %>% group_by(GROUP) %>%  summarise(Cmax = max(CTOTngmL))
  })
    }
  )
  
  observeEvent(
    input$run_simulation, {
  output$plot_mAb <- renderPlot({
    data$simout %>% 
      ggplot(aes(x = time, y = CTOTngmL, group = GROUP, colour = factor(GROUP))) +
      geom_line() +
      theme_bw() +
      labs(y = 'mAb concentration (ng/mL)',
           x = 'Time (days)',
           colour = '') +
      theme(legend.position = 'bottom')
  })
    }
)

  
})