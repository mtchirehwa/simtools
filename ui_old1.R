# Author: Maxwell Chirehwa
# Date Created: 05-July-2022
# Date Modified: XXXX
# Description: Shiny UI for TMDD model simulator

list.of.packages <-
  c('base', "survival", 'mstate', 'diagram', "shiny", 'shinyjs',
    'colourpicker', 'xtable',  'shinyBS', 'mrgsolve', 'shinydashboard')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')

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

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
  input[type=\"number\"] {
    height: 20px;
  }
    input[type=\"text\"] {
    height: 20px;
  }

"))
  ),

  # Meta-information
  theme = "bootstrap.css", # Gives app unique feel (Copyright (c) 2013 Thomas Park)
  useShinyjs(),  # allows use of shinyjs package
  withMathJax(), # allows use of mathematical symbols
  titlePanel('TMDD model simulator'),
  
  ### Main body ###
  tabsetPanel(
    id = 'tabs',
    
    # Tab 1: Full TMDD
    tabPanel(
      'Full TMDD', 
      fluidRow(
        column(
          12, 
          h1('Under construction')
        )
      )
    ),
    
    # Tab 2: QE approximation
    tabPanel(
      'QE approximation', 
       fluidRow(
         # column(
         #   4, 
         #   h4('Enter simulation info'),
         #   uiOutput('qeUI')
         # )
         box(title = "Parameters",
             tipify(
               numericInput('TVCL', 'CL (L/day)', min = 0.0001, value = 250, width = '100%'),
               'Clearance in L/day'
             ), 
             tipify(
               numericInput('TVV1', 'VC (L)', min = 0.1, value = 250, width = '100%'),
               'Volume of distribution - Central compartment in L'
             ),
             tipify(
               numericInput('TVQ1', 'Q (L/day)', min = 2, value = 250, width = '100%'),
               'IIntercompartmental clearance in L/day'
             ), 
             tipify(
               numericInput('TVV2', 'VT (L)', min = 0.1, value = 250, width = '100%'),
               'Volume of distribution - tissue compartment in L'
             ), 
             tipify(
               numericInput('TVKA', 'Ka (/day)', min = 0.1, value = 250, width = '100%'),
               'Absorption rate constant in /day'
             )
             , 
             tipify(
               numericInput('TVF1', 'F1 (Proportion)', min = 0, value = 0.744, max = 1, width = '100%'),
               'Bioavailability'
             ),
             width = 2
         )
       )
    ),
    
    # Tab 3: QSS approximation
    tabPanel(
      'QSS approximation', 
      fluidRow(
        column(
          12, 
          h1('Under construction')
        )
      )
    )
    
    
  )
  
)