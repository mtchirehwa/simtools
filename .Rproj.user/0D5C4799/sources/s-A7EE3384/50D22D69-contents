# Author: Maxwell Chirehwa
# Date Created: 05-July-2022
# Date Modified: XXXX
# Description: Shiny server for TMDD model simulator

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

server <- function(input, output, session) {
  
  output$qeUI <- renderUI({
    fluidRow(
      fluidRow(
      column(4, 
             h5("Insert PK parameters"),
             # PK inputs
             verticalLayout(
               inputPanel(
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
                 )
               )
             )
      ),
      column(4, 
             h5("Insert TE parameters"),
             # QE approximation parameters
             verticalLayout(
               inputPanel(
                 tipify(
                   numericInput('TVBASE', 'Baseline (nM)', min = 0.0001, value = 5, width = '100%'),
                   'Baseline value of target in nM'
                 ),
                 tipify(
                   numericInput('TVKDEG', 'Kdeg (/day)', min = 0.0001, value = 5, width = '100%'),
                   'Degradation rate of target (/day)'
                 ),
                 tipify(
                   numericInput('TVKINT', 'Kint (/day)', min = 0.0001, value = 5),
                   'Internalization rate (/day)'
                 ),
                 tipify(
                   numericInput('TVKD', 'Kd (nM)', value = 5),
                   'Equilibrium dossiciation constant (nM)'
                 ),
                 tipify(
                   numericInput('MWmAb', 'mAb weight (kDa)', value = 150),
                   'Molecular weight of mAb'
                 ),
                 tipify(
                   numericInput('MWtarget', 'Target weight (kDa)', value = 14),
                   'Molecular weight of target'
                 )
               )
             )
      )
    ),
    fluidRow(
      column(8, 
             h5("Insert Dosing info")
    )
    ),
    fluidRow(
      column(4, 
             verticalLayout(
               inputPanel(
                 tipify(
                 textInput('DOSES', 'Dose (mg)', value = 5),
                 'Enter doses levels separated by comma'
                 ),
                 tipify(
                   numericInput('simstart', 'Start time', value = 0),
                   'Simulation start time'
                 )
               ))
      ),
      column(4, 
             verticalLayout(
               inputPanel(
                 tipify(
                   textInput('doseint', 'Dose int', value = 5),
                   'Enter dosing interval separated by comma'
                 ),
                 tipify(
                   numericInput('simstop', 'Stop time', value = 28),
                   'Simulation start time'
                 )
               ))
      )
    )
    )
  })
  
  output$fullUI <- renderUI({
    fluidRow(
      column(12, 
             h2("Under construction")
      )
    )
  })
  
}