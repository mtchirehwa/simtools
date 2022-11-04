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
  
  # deleting a input design
  observeEvent(input$deletePressed, {
    rowNum <- parseDeleteEvent(input$deletePressed)
    # Delete the row from the data frame
    data$pkteparams <- data$pkteparams[-rowNum,]
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
                                   ev(amt=tempdata$amt) %>% 
                                   mrgsim(end = tempdata$Sim_stop,
                                          delta = tempdata$Sim_step, 
                                          start = tempdata$Sim_start,
                                          obsonly = T) %>% 
                                   as_tibble()
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

  
})