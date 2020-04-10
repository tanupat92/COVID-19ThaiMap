# COVID-19ThaiMap
This is an interactive map made by R Shiny and leaflet. The dataset is from DDC, Thailand. 

## Getting Started

You can use R to run the application straight from GitHub. (Need to install required packages first. See Below.)

```
library(shiny)
runGitHub('tanupat92/COVID-19ThaiMap')
```
or try using the application at https://tanupat-boon.shinyapps.io/COVID-19Thaimap/

### Prerequisites

First, you need to install R and Rstudio. Then, you must install these libraries.

```
install.packages(c('shiny', 'leaflet', 'shinythemes', 'shinyWidgets', 'httr', 'jsonlite', 'readr', 'dplyr', 'tidyr', 'lubridate', 'ggplot2', 'plotly'))

```

## Dataset

All data is from Department of Disease Control under Ministry of Public Health, Thailand. 
The dataset is requested via API provided from this [link](https://covid19.th-stat.com/th/api).
Fields of the dataset are *Age*, *Sex*, *Nationality*, *DateConfirm*, and *Province*. 
Latitudes and longitudes of each provinces are from https://opendata.data.go.th/dataset/item_c6d42e1b-3219-47e1-b6b7-dfe914f27910


## Built With

* [R Shiny](https://shiny.rstudio.com/) - make interactive web application straight from R
* [Leaflet for R](https://rstudio.github.io/leaflet/) - the most popular open-source JavaScript libraries for interactive maps

## Authors

* **Tanupat Boonchalermvichien, MD.** - *Initial work* - [Dara Network](https://tanupat-boon.shinyapps.io/dara_network/)

## Credits

* [DDC MOPH Thailand](https://ddc.moph.go.th/) - Data
* [KIDKARNMAI](http://www.kidkarnmai.com/) - Develop API
* [Thailand COVID19 Digital Group (TCDG)](https://www.facebook.com/groups/192150165377624/) - Group of Devs for COVID-19 
* [SmileHost](https://smilehost.asia/) - Host server for API


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details



