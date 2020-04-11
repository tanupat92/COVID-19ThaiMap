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
library(ggplot2)
library(plotly)

url1 = 'https://covid19.th-stat.com/api/open/cases'
url2 = 'https://covid19.th-stat.com/api/open/today'
coord <- read_csv('latlongprovince.csv')
r <- GET(url1)
s <- GET(url2)
C <- content(s, as = 'text', encoding = 'UTF-8')
J <- fromJSON(C)
confirmed <- J$Confirmed
recovered <- J$Recovered
deaths <- J$Deaths
new <- J$NewConfirmed
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
  observe({
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
        radius = 5,
        fillColor = 'red', color = 'red', weight = 1
      )
    
  })
  output$newcase <- plotly::renderPlotly({
    ggplotly(rvalData()%>% group_by(date_confirmed) %>% count() %>% ggplot(aes(x= date_confirmed, y = n)) + 
               geom_line(col='red')+ theme_bw() + 
               ylab("new cases") + xlab('date') + 
               scale_x_date(date_labels = "%b") + 
               theme(plot.margin = margin(5,5,5,5))
    )
  })
  output$cumulativecase <- plotly::renderPlotly({
    rvalData()%>% group_by(date_confirmed) %>% count() %>% ungroup() %>% 
      mutate(csum = cumsum(n)) %>% ggplot(aes(x= date_confirmed, y = csum)) + 
      geom_line(col='red')+ theme_bw() + ylab("cumulative cases") + 
      xlab('date') + scale_x_date(date_labels = "%b")
  })
  
  
  output$myweb <- renderUI({
    tagList("See", a('COVID-19 DDC', href='https://covid19.th-stat.com/th'))
  })
  output$number1 <- renderUI({tags$h4('Total ', confirmed, ' cases')})
  output$number2 <- renderUI({tags$body(recovered, ' recovered  ', deaths, ' deaths  ', new, ' new cases' )}) 
  output$update <- renderUI({
    tags$i('This data is up to', date_update)
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
                                  
                                  Copyright (c) 2020 Tanupat B.'),title='About'
    )
    )
  })

}
