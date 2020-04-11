#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(plotly)
library(shinycssloaders)

shinyUI(bootstrapPage(
  
  theme = shinythemes:: shinytheme('simplex'),
  
  leaflet::leafletOutput('map', width = '100%', height = '100%'),
  absolutePanel(top=10, right=10, id='controls', class = "panel panel-default", fixed = FALSE, draggable = FALSE,
                HTML('<button data-toggle="collapse" data-target="#demo">Hide</button>'),
                tags$div(id='demo', class="collapse in",
                         uiOutput('number1'),
                         uiOutput('number2'),
                         uiOutput('update'),
                         shinyWidgets::sliderTextInput('agerange', 'Age range:',
                                                       choices = 0:100,
                                                       from_min = NULL,
                                                       from_max = NULL,
                                                       to_min = NULL,
                                                       to_max = NULL,
                                                       selected = c(0,100), hide_min_max = TRUE),
                         dateRangeInput("daterange", "Select confirmed date:", start = NULL, end = NULL, min = NULL,
                                        max = NULL, format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                                        language = "en", separator = " to ", width = NULL),
                         shinyWidgets::awesomeCheckboxGroup('sex', NULL, choices=c('Male','Female'),
                                                            selected= c('Male','Female'), inline =TRUE),
                         shinyWidgets::pickerInput(
                           'nations', 'Nationality:', choices=NULL, multiple = TRUE, selected = NULL),
                         shinyWidgets::switchInput(
                           "allnation",
                           label = "Nationality", onLabel = "All", offLabel = "None", value = TRUE, size = 'mini'),
                         plotlyOutput('newcase', height = '130px', width = '100%') %>% withSpinner(type = 4),
                         plotlyOutput('cumulativecase', height = '130px', width = '100%') %>% withSpinner(type = 4),
                         uiOutput('myweb'),
                         tags$style(type = 'text/css',"html, body {width:100%;height:100%}
                                    #controls {backgroud-color:white;padding:10px;opacity:0.8"),
                         actionButton('showabout', 'About', icon = icon('question-circle')))
                
                )
  
))


