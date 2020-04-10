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


shinyUI(bootstrapPage(
  
  theme = shinythemes:: shinytheme('simplex'),
  
  leaflet::leafletOutput('map', width = '100%', height = '100%'),
  absolutePanel(top=10, right=10, id='controls', clas = "panel panel-default", fixed = TRUE, draggable = FALSE,
                HTML('<button data-toggle="collapse" data-target="#demo">Hide</button>'),
                tags$div(id='demo', class="collapse in",
                         shinyWidgets::sliderTextInput('agerange', 'Age range:',
                                                       choices = 0:100,
                                                       from_min = NULL,
                                                       from_max = NULL,
                                                       to_min = NULL,
                                                       to_max = NULL,
                                                       selected = c(0,100)),
                         dateRangeInput("daterange", "Select confirmed date:", start = NULL, end = NULL, min = NULL,
                                        max = NULL, format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                                        language = "en", separator = " to ", width = NULL),
                         shinyWidgets::awesomeCheckboxGroup('sex', 'Sex:', choices=c('Male','Female'),
                                                            selected= c('Male','Female'), inline =TRUE),
                         shinyWidgets::switchInput(
                           "allnation",
                           label = "Nationality", onLabel = "All", offLabel = "None", value = TRUE),
                         shinyWidgets::pickerInput(
                           'nations', 'Nationality:', choices=NULL, multiple = TRUE, selected = NULL),
                         uiOutput('update'),
                         uiOutput('myweb'),
                         tags$style(type = 'text/css',"html, body {width:100%;height:100%}
                                    #controls{backgroud-color:white;padding:20px;"),
                         actionButton('showabout', 'About', icon = icon('question-circle')))
                
                )
  
))


