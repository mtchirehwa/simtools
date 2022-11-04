
library(shinycssloaders)
library(plotly)
library(markdown)
library(shinydashboard)
library(DT)
shinyUI(
  shinydashboard::dashboardPage(title = "ShinyAB",
                #dashboardHeader(title = logo_grey_light, titleWidth = 200),
                dashboardHeader(title = tag("font", list(size="6", "TMDDsim")), titleWidth = 200),
                dashboardSidebar(
                  collapsed = T,
                  width = 200,
                  sidebarMenu(
                    menuItem("QE approx", icon = icon("th"), tabName = "qe_approx"),
                    menuItem("Full TMDD", icon = icon("github"), tabName = "full_tmdd")
                  )
                ),
                dashboardBody(
                  #theme_grey_light,
                  tabItems(
                    tabItem(tabName = "qe_approx",
                            fluidRow(
                              shinydashboard::box(title = "PK Parameters", width = '4', solidHeader = T, status = "primary", 
                                  fluidRow(
                                    column(3, 
                                           p(HTML("<b>TVCL (L/day)</b>"),span(shiny::icon("info-circle"), id = "info_CL"),numericInput('TVCL', NULL, 0.2),
                                             tippy::tippy_this(elementId = "info_CL",tooltip = "Clearance in L/day",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>VC (L)</b>"),span(shiny::icon("info-circle"), id = "info_V1"),numericInput('TVV1', NULL, 2),
                                             tippy::tippy_this(elementId = "info_V1",tooltip = "Volume of distribution - Central compartment in L",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>TVQ1 (L/day)</b>"),span(shiny::icon("info-circle"), id = "info_Q1"),numericInput('TVQ1', NULL, 0.2),
                                             tippy::tippy_this(elementId = "info_Q1",tooltip = "Intercompartmental clearance in L/day",placement = "right")
                                           )
                                    )
                                  ),
                                  fluidRow(
                                    column(3, 
                                           p(HTML("<b>VP (L)</b>"),span(shiny::icon("info-circle"), id = "info_V2"),numericInput('TVV2', NULL, 2),
                                             tippy::tippy_this(elementId = "info_V2",tooltip = "Volume of distribution - Peripheral compartment in L",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>KA (/day)</b>"),span(shiny::icon("info-circle"), id = "info_KA"),numericInput('TVKA', NULL, 2),
                                             tippy::tippy_this(elementId = "info_KA",tooltip = "Absorption rate constant in /day",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>Bio (prop)</b>"),span(shiny::icon("info-circle"), id = "info_F1"),numericInput('TVF1', NULL, 0.74),
                                             tippy::tippy_this(elementId = "info_F1",tooltip = "Bioavailability [0-1]",placement = "right")
                                           )
                                    )
                                  ),
                                  uiOutput("ui_test_method_parameter"),
                                  fluidRow(
                                    column(4, actionButton("add_btn", "Add Record"))
                                  )     
                              ),
                              box(title = "TE Parameters", width = 4, solidHeader = T, status = "primary", 
                                  fluidRow(
                                    column(3, 
                                           p(HTML("<b>BASE (nM)</b>"),span(shiny::icon("info-circle"), id = "info_TVBASE"),numericInput('TVBASE', NULL, 0.2),
                                             tippy::tippy_this(elementId = "info_TVBASE",tooltip = "Baseline value of target",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>KDEG (/day)</b>"),span(shiny::icon("info-circle"), id = "info_KDEG"),numericInput('TVKDEG', NULL, 2),
                                             tippy::tippy_this(elementId = "info_KDEG",tooltip = "Degradation rate of target (/day)",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>KINT (/day)</b>"),span(shiny::icon("info-circle"), id = "info_KINT"),numericInput('TVKINT', NULL, 0.2),
                                             tippy::tippy_this(elementId = "info_KINT",tooltip = "Internalization rate (/day)",placement = "right")
                                           )
                                    )
                                  ),
                                  fluidRow(
                                    column(3, 
                                           p(HTML("<b>KD (nM)</b>"),span(shiny::icon("info-circle"), id = "info_KD"),numericInput('TVKD', NULL, 2),
                                             tippy::tippy_this(elementId = "info_KD",tooltip = "Equilibrium dossiciation constant (nM)",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>mAb weight (kDa)</b>"),span(shiny::icon("info-circle"), id = "info_MWmAb"),numericInput('MWmAb', NULL, 150),
                                             tippy::tippy_this(elementId = "info_MWmAb",tooltip = "Molecular weight of mAb in kDa",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>Target weight (kDa)</b>"),span(shiny::icon("info-circle"), id = "info_MWtarget"),numericInput('MWtarget', NULL, 15),
                                             tippy::tippy_this(elementId = "info_MWtarget",tooltip = "Molecular weight of target in kDA",placement = "right")
                                           )
                                    )
                                  )
                              ),
                              shinydashboard::box(title = "Dosing & Simulation", width = 4, solidHeader = T, status = "primary", 
                                  fluidRow(
                                    column(3, 
                                           p(HTML("<b>Dose (mg)</b>"),span(shiny::icon("info-circle"), id = "info_Dose"),numericInput('Dose', NULL, 150),
                                             tippy::tippy_this(elementId = "info_Dose",tooltip = 'Enter dose levels in mg', placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>II (days)</b>"),span(shiny::icon("info-circle"), id = "info_II"),numericInput('II', NULL, 999),
                                             tippy::tippy_this(elementId = "info_II",tooltip = "Enter dosing intervals in days. Enter a large number for single dose simulation",placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>ADDL </b>"),span(shiny::icon("info-circle"), id = "info_ADDL"),numericInput('ADDL', NULL, 0),
                                             tippy::tippy_this(elementId = "info_ADDL",tooltip = "Additional doses",placement = "right")
                                           )
                                    )
                                  ),
                                  fluidRow(
                                    column(3, 
                                           p(HTML("<b>SIM_START (days)</b>"),span(shiny::icon("info-circle"), id = "info_SIM_START"),numericInput('Sim_start', NULL, 0),
                                             tippy::tippy_this(elementId = "info_SIM_START",tooltip = 'Enter simulation start time', placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>SIM_STOP (days)</b>"),span(shiny::icon("info-circle"), id = "info_SIM_STOP"),numericInput('Sim_stop', NULL, 30),
                                             tippy::tippy_this(elementId = "info_SIM_STOP",tooltip = 'Enter simulation stop time', placement = "right")
                                           )
                                    ),
                                    column(3, 
                                           p(HTML("<b>SIM_STEP (days)</b>"),span(shiny::icon("info-circle"), id = "info_SIM_STEP"),numericInput('Sim_step', NULL, 1),
                                             tippy::tippy_this(elementId = "info_SIM_STEP",tooltip = 'Enter simulation step size or delta', placement = "right")
                                           )
                                    )
                                  )
                              ),
                              # shinydashboard::box(title = "Simulation set", width = 12, solidHeader = T, status = "success", 
                              #                     tabPanel("SIMULATIONDATA",
                              #                              dataTableOutput("TBL1"))
                              #     # tableOutput("kable_proportion"),
                              #     # fluidRow(
                              #     #   column(1, actionButton("btn_remove", "Remove Record")),
                              #     #   column(1, uiOutput("ui_dlbtn")),
                              #     #   column(10, uiOutput("ui_unvisible_columns"))
                              #     # )
                              # ),
                              tabBox(
                                title = "", width = 12,
                                id = "tabset1",
                                tabPanel(HTML("<b>Simulation inputs</b>"),
                                         div(style = 'overflow-x: scroll',DT::dataTableOutput("TBL1",width = "100%")),
                                         fluidRow(
                                           column(4, actionButton("run_simulation", "Start simulation"))
                                         )),
                                tabPanel(HTML("<b>Simulated data</b>"),
                                         div(style = 'overflow-x: scroll',DT::dataTableOutput("simdata",width = "100%"))
                                         )
                              ),
                              tabBox(
                                title = HTML("<b>Plots</b>"), width = 6,
                                id = "tabset2",
                                tabPanel("Compound",
                                         div(shiny::plotOutput('plot_mAb',width = "100%"))),
                                tabPanel("Complex"),
                                tabPanel("Target Engagement"),
                                tabPanel("Target")
                              ),
                              tabBox(title = HTML("<b>Summaries</b>"), width = 6, 
                                     id = "tabset3",
                                     tabPanel("Compound",
                                              div(DT::dataTableOutput("summary_mAb",width = "100%"))),
                                     tabPanel("Complex"),
                                     tabPanel("Target Engagement"),
                                     tabPanel("Target")
                              )
                            )
                    ),
                    tabItem(tabName = "full_tmdd")
                  )
                )
  )
)