
library(shinycssloaders)
library(plotly)
library(markdown)
shinyUI(
  dashboardPage(title = "ShinyAB",
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
                              box(title = "PK Parameters", width = '4', solidHeader = T, status = "primary", 
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
                                           p(HTML("<b>Bio (prop)</b>"),span(shiny::icon("info-circle"), id = "info_F1"),numericInput('TVF1', NULL, 2),
                                             tippy::tippy_this(elementId = "info_F1",tooltip = "Bioavailability [0-1]",placement = "right")
                                           )
                                    )
                                  ),
                                  uiOutput("ui_test_method_parameter"),
                                  fluidRow(
                                    column(4, actionButton("btn_go", "Add Record"))
                                  )     
                              ),
                              box(title = "TE Parameters", width = 4, solidHeader = T, status = "primary", 
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
                                           p(HTML("<b>Bio (prop)</b>"),span(shiny::icon("info-circle"), id = "info_F1"),numericInput('TVF1', NULL, 2),
                                             tippy::tippy_this(elementId = "info_F1",tooltip = "Bioavailability [0-1]",placement = "right")
                                           )
                                    )
                                  )
                              ),
                              box(title = "Dosing & Simulation", width = 4, solidHeader = T, status = "primary", 
                                  tableOutput("kable_error_matrix")
                              ),
                              box(title = "Table", width = 12, solidHeader = T, status = "success", 
                                  tableOutput("kable_proportion"),
                                  fluidRow(
                                    column(1, actionButton("btn_remove", "Remove Record")),
                                    column(1, uiOutput("ui_dlbtn")),
                                    column(10, uiOutput("ui_unvisible_columns"))
                                  )
                              ),
                              tabBox(
                                title = "", width = 6,
                                id = "tabset1",
                                tabPanel("Sample Size × Lift", plotlyOutput("simulation_plot") %>% withSpinner(type = 5)),
                                tabPanel("Running Lift", plotlyOutput("running_lift") %>% withSpinner(type = 5))
                              ),
                              tabBox(title = "", width = 6, 
                                     id = "tabset2",
                                     tabPanel("Reject region and Power", plotlyOutput("rrp_plot") %>% withSpinner(type = 5)),
                                     tabPanel("Probability Mass Function", plotlyOutput("pmf_plot") %>% withSpinner(type = 5))
                              )
                            )
                    ),
                    tabItem(tabName = "full_tmdd")
                  )
                )
  )
)