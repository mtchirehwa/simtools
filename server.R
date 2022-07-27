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
#library(shinydashboardPlus)
library(DT)
library(tibble)

mod_qe <- mread_cache("analyses/TMDD_QE_2cmt_pop")
mod_full <- mread_cache("analyses/Full_TMDD_2cmt_pop")

# Dummy tibble to initialize the dataframe of parameters
dummyInp <- tibble(TVCL = 0,
                   TVV1 = 0,
                   TVQ1 = 0,
                   TVV2 = 0,
                   TVKA = 0,
                   TVF1 = 0,
                   TVBASE = 0,
                   TVKDEG = 0,
                   TVKINT = 0,
                   TVKD = 0,
                   MWmAb = 0,
                   MWtarget = 0,
                   Dose = 0,
                   II = 0,
                   ADDL = 0,
                   Sim_start = 0,
                   Sim_stop = 0,
                   Sim_step = 0
                   )

shinyServer(function(input, output, session){
  print("Initialize Start")
  
  # Add input to dataframe
  ## Init with some example data
  data <- reactiveVal(dummyInp)
  
  observeEvent(
    input$add_btn,
    {
      #start with current data
      data() %>%
        filter_all(., any_vars(. != 0)) %>% 
        add_row(
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
        ) %>%
        # update data value
        data() 

    }
  )
  
  observeEvent(input$deletePressed, {
    rowNum <- parseDeleteEvent(input$deletePressed)
    # Delete the row from the data frame
    data() %>%  filter(row_number() != rowNum) %>% data()
  })

  output$TBL1 <- renderDataTable(
    # datatable(data()) ## old code
    # Add the delete button column
    deleteButtonColumn(data() , 'delete_button')

  )

  
})