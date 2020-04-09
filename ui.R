#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(leaflet)
library(shinythemes)
library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)
library(readr)
library(shinyWidgets)
library(tidyr)


url = 'https://covid19.th-stat.com/api/open/cases'

coord <- read_csv('latlongprovince.csv')
r <- GET(url)
date_request <- headers(r)$date
Content <- content(r, as = 'text', encoding = 'UTF-8')
json <- fromJSON(Content)
data_pre <- json$Data
date_update <- json$UpdateDate
source <- json$Source
dev <- json$DevBy
data <- data_pre %>% mutate(date_confirmed = as_date(ConfirmDate), sex = factor(GenderEn), nationality = factor(NationEn),
                            province_id = ProvinceId, province = factor(ProvinceEn)) %>%
                    select(date_confirmed, sex, age = Age,nationality, province, province_id) %>% unite('summary', date_confirmed:province, remove = FALSE)
minage = min(data$age)
maxage = max(data$age)
nationality = levels(data$nationality) 
earlydate = min(data$date_confirmed)
latedate = max(data$date_confirmed)
data <- data %>% left_join(coord, by = 'province_id')
long <- sapply(data[,c('long')], function(x){x+runif(1,-0.05,0.05)})
lat <- sapply(data[,c('lat')], function(x){x+runif(1,-0.05,0.05)})
data$long <- long
data$lat <- lat

shinyUI(bootstrapPage(

   theme = shinythemes:: shinytheme('simplex'),
    
   leaflet::leafletOutput('map', width = '100%', height = '100%'),
   absolutePanel(top=10, right=10, id='controls',
                 shinyWidgets::sliderTextInput('agerange', 'Age range:',
                             choices = 0:100,
                             from_min = minage,
                             from_max = maxage,
                             to_min = minage,
                             to_max = maxage,
                             selected = c(30,60)),
                 dateRangeInput("daterange", "Select confirmed date:", start = earlydate, end = latedate, min = earlydate,
                                max = latedate, format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                                language = "en", separator = " to ", width = NULL),
                 shinyWidgets::awesomeCheckboxGroup('sex', 'Sex:', choices=c('Male','Female'),
                                      selected= c('Male','Female'), inline =TRUE),
                 shinyWidgets::switchInput(
                   "allnation",
                   label = "Nationality", onLabel = "All", offLabel = "None", value = TRUE),
                 shinyWidgets::pickerInput(
                   'nations', 'Nationality:', choices=nationality, multiple = TRUE, selected = nationality),
                 
                 tags$body(paste("This data is up to", date_update)),
                 uiOutput('myweb'),
                 tags$style(type = 'text/css',"html, body {width:100%;height:100%}
                            #controls{backgroud-color:white;padding:30px;"),
                 actionButton('showabout', 'About', icon = icon('question-circle'))
  
                 )
   
))


