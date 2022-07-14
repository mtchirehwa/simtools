# Author: Maxwell Chirehwa
# Date Created: 05-July-2022
# Date Modified: XXXX
# Description: Shiny Application for tmdd model simulations using mrgsove

## Makes sure packages are installed
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

remove(list = objects())

#source('shiny_helpers.R')
#source('plot_statefig.R')

runApp('.')