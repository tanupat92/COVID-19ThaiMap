server <- function(input, output, session) {
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
  output$devweb <- renderUI({
    tagList("API developed by", url2)
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
    url1 <- a("GitHub", href="http://github.com/tanupat92/")
    showModal(modalDialog(tags$li('The data is from http://covid19.th-stat.com/th/api which belongs to Department of Disease Control under 
                          Ministry of Public Health, Thailand. This dataset is updated daily. All data points are not located at exact places.'),
                          tags$li('API is developed by KIDKARNMAI'),
                          tags$li('This application is developed by Tanupat B. See codes at'), tags$a(url1),
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
