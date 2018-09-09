library(dplyr)
library(tidyr)
library(leaflet)
library(rgdal)
library(DT)

#run utils.R and getData.R

# data downloaded from http://data.london.gov.uk/dataset/statistical-gis-boundary-files-london
#boroughs<-readOGR(dsn="Data/statistical-gis-boundaries-london/ESRI", layer="London_Borough_Excluding_MHW")

sao_paulo <- readOGR("SP-MUN", "35MUE250GC_SIR")
nomes <-read.csv("nomes.csv")
nomes <- reduceorder(nomes, 1)
colnames(nomes) <- c("COD_MUN", "Nome")

# Cut out unnecessary columns
#boroughs@data<-boroughs@data[,c(1,2)]

sao_paulo@data <- reduceorder(sao_paulo@data, 1)
head(sao_paulo@data)
sao_paulo@data <- as.data.frame(sao_paulo@data[,2])
colnames(sao_paulo@data) <- c("COD_MUN")

# transform to WGS884 reference system 
#boroughs<-spTransform(boroughs, CRS("+init=epsg:4326"))

sao_paulo <- spTransform(sao_paulo, CRS("+init=epsg:4326"))

# Find the edges of our map
#bounds<-bbox(boroughs)

bounds <- bbox(sao_paulo)
# Get the income data 
#income_long<-read.csv("Data/income_long.csv")

dados_sp <- getData()
head(dados_sp, n=30)
function(input, output, session){
  
  getDataSet<-reactive({
    
    # Get a subset of the income data which is contingent on the input variables
    #dataSet<-income_long[income_long$Year==input$dataYear & income_long$Measure==input$meas,]
    dataSet <- dados_sp[dados_sp$Ano==input$selecAno & dados_sp$Indicador==input$indicador,]
    print("dadosSp")
    print(head(dados_sp))
    # Copy our GIS data
    #joinedDataset<-boroughs
    
    joinedDataset <- sao_paulo
    #oinedDataset@data <- suppressWarnings(left_join(joinedDataset@data, dataSet, by="COD_MUN"))
    joinedDataset@data <- merge(joinedDataset@data, dataSet, by = "COD_MUN", all=TRUE)
    joinedDataset@data <- merge(joinedDataset@data, nomes, by="COD_MUN", all=TRUE)
    #joinedDataset@data <- joinedDataset@data[!is.na(joinedDataset@data$Nome),]
    # Join the two datasets together
    #joinedDataset@data <- suppressWarnings(left_join(joinedDataset@data, dataSet, by="NAME"))
    
    # If input specifies, don't include data for City of London
    #if(input$city==FALSE){
     # joinedDataset@data[joinedDataset@data$NAME=="City of London",]$Income=NA
    #}
    
    print(head(joinedDataset@data))
    joinedDataset
  })
  
  # Due to use of leafletProxy below, this should only be called once
  output$spMap<-renderLeaflet({
    
    leaflet() %>%
      addTiles() %>%
      
      # Centre the map in the middle of our co-ordinates
      setView(mean(bounds[1,]),
              mean(bounds[2,]),
              zoom=7 # set to 10 as 9 is a bit too zoomed out
      )       
    
  })
  
  
  
  observe({
    theData<-getDataSet()
    print("theData")
    print(head(theData@data))
    # colour palette mapped to data
    pal <- colorQuantile("YlOrRd", theData$Valor, n = 10) 
    
    # set text for the clickable popup labels
    borough_popup <- paste0("<strong>Cidade: </strong>", 
                            theData$Nome, 
                            "<br><strong>",
                            input$Indicador," 
                            Valor: </strong>", 
                            formatC(theData$Valor, big.mark=',')
    )
    
    # If the data changes, the polygons are cleared and redrawn, however, the map (above) is not redrawn
    leafletProxy("spMap", data = theData) %>%
      clearShapes() %>%
      addPolygons(data = theData,
                  fillColor = pal(theData$Valor), 
                  fillOpacity = 0.8, 
                  color = "#BDBDC3", 
                  weight = 2,
                  popup = borough_popup)  
    
  })
  
  # table of results, rendered using data table
  output$spTable <- renderDataTable(datatable({
    dataSet<-getDataSet()
    dataSet<-dataSet@data[,c(5,3)] # Just get name and value columns
    names(dataSet)<-c("Cidade",paste0(input$Indicador," Valor") )
    dataSet
  },
  options = list(lengthMenu = c(5, 10, 33), pageLength = 5))
  )
  
  # year selecter; values based on those present in the dataset
  output$selecAno<-renderUI({
    yearRange<-sort(unique(as.numeric(as.character(dados_sp$Ano))), decreasing=TRUE)
    selectInput("selecAno", "Ano", choices=yearRange, selected=yearRange[1])
  })
}