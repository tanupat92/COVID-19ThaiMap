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

server <- function(input, output, session) {
  observe({updateSliderTextInput(session = session, inputId = 'agerange', 
                                 from_fixed  = minage,
                                 to_fixed = maxage)
          updateDateRangeInput(session=session, inputId = 'daterange', start = earlydate, end = latedate, min = earlydate,
                               max = latedate)
          updatePickerInput(session=session, inputId = 'nations', selected = nationality, choices = nationality)})
  rvalData <- reactive({data %>% filter(
    date_confirmed >= input$daterange[1],
    date_confirmed <= input$daterange[2],
    age >= input$agerange[1],
    age <= input$agerange[2],
    sex %in% input$sex,
    nationality %in% input$nations
  ) })
  output$map <- leaflet::renderLeaflet({
    rvalData() %>%
      leaflet(options = leafletOptions(crs = leafletCRS(crsClass = "L.CRS.EPSG3857")))%>%
      addTiles() %>%
      setView(100.59,13.92, zoom = 6) %>%
      addTiles() %>%
      addCircleMarkers(
        popup = ~ summary,
        radius = 10,
        fillColor = 'red', color = 'red', weight = 1
      )
    
  })
  
  
  output$myweb <- renderUI({
    tagList("See", a('COVID-19 DDC', href='https://covid19.th-stat.com/th'))
  })
  output$update <- renderUI({
    tagList('This data is up to', body=date_update)
  })
  
  observeEvent(input$allnation, {
    if (input$allnation){
      updatePickerInput(session = session, inputId = "nations",
                        selected = nationality)
    } else{
      updatePickerInput(session = session, inputId = "nations",
                        selected = NULL, choices = nationality)
    }
  })
  
  observeEvent(input$showabout,{
    url1 <- a("GitHub", href="https://github.com/tanupat92/COVID-19ThaiMap")
    showModal(modalDialog(tags$li('The data is from http://covid19.th-stat.com/th/api which belongs to Department of Disease Control under 
                          Ministry of Public Health, Thailand. This dataset is updated daily. All data points are not located at exact places.'),
                          tags$li('API is developed by KIDKARNMAI'), 
                          tags$li('This application is developed by Tanupat B. See codes at', a(url1)), 
                          tags$li('MIT License

                                  Copyright (c) 2020 Tanupat B. 
                                  
                                  Permission is hereby granted, free of charge, to any person obtaining a copy
                                  of this software and associated documentation files (the "Software"), to deal
                                  in the Software without restriction, including without limitation the rights
                                  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                                  copies of the Software, and to permit persons to whom the Software is
                                  furnished to do so, subject to the following conditions:
                                  
                                  The above copyright notice and this permission notice shall be included in all
                                  copies or substantial portions of the Software.
                                  
                                  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                                  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                                  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                                  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                                  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                                  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                                  SOFTWARE.'),title='About'
    )
    )
  })
}
