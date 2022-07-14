# Author: Maxwell Chirehwa
# Date Created: 05-July-2022
# Date Modified: XXXX
# Description: Shiny server for TMDD model simulator

list.of.packages <-
  c('base', "survival", 'mstate', 'diagram', "shiny", 'shinyjs',
    'colourpicker', 'xtable',  'shinyBS', 'mrgsolve', 'shinydashboard', 'shinycssloaders', 'plotly')
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
library(shinycssloaders)
library(plotly)
library(markdown)

mod_qe <- mread_cache("analyses/TMDD_QE_2cmt_pop")
mod_full <- mread_cache("analyses/Full_TMDD_2cmt_pop")

shinyServer(function(input, output, session){
  print("Initialize Start")
})