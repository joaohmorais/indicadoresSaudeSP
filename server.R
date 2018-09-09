library(plyr)
library(dplyr)
library(tidyr)
library(leaflet)
library(rgdal)
library(DT)

#run utils.R and getData.R

#spatial data
sao_paulo <- readOGR("SP-MUN", "35MUE250GC_SIR")
sao_paulo_rras <- readOGR("rras_data", "sp_rras")


#nomes dos municípios
nomes <-read.csv("nomes.csv")
nomes <- reduceorder(nomes, 1)
colnames(nomes) <- c("COD_MUN", "Nome")

#nomes das RRAS
# plot(sao_paulo_rras, col=colors)
# text(coordinates(sao_paulo_rras), labels=sao_paulo_rras$Nome, cex=0.8)

 colnames(sao_paulo_rras@data) <- c("COD_MUN", "Nome")


sao_paulo@data <- reduceorder(sao_paulo@data, 1) #conserta os IDs
head(sao_paulo@data)
sao_paulo@data <- as.data.frame(sao_paulo@data[,2]) #sem os atributos desnecessários
colnames(sao_paulo@data) <- c("COD_MUN") #para unificar

#transformar sistema
sao_paulo <- spTransform(sao_paulo, CRS("+init=epsg:4326"))
sao_paulo_rras <- spTransform(sao_paulo_rras, CRS("+init=epsg:4326"))

#cantos do mapa
bounds <- bbox(sao_paulo)

#dados
dados_sp <- getData()
head(dados_sp, n=30)

function(input, output, session){
  
  getPolygonData<-reactive({
    
    spatialData <- sao_paulo
    
    if (input$ordem == "RRAS") {
      spatialData <- sao_paulo_rras
    }
    
    return (spatialData)
  })
  
  getDataSet<-reactive({
    
    #subset data
    dataSet <- dados_sp[dados_sp$Ano==input$selecAno & dados_sp$Indicador==input$indicador & dados_sp$GeoType == input$ordem,]
    
    #verifica se foi certo
    # print("dadosSp")
    # print(head(dados_sp))
    
    joinedDataset <- getPolygonData()
    joinedDataset@data <- join(joinedDataset@data, dataSet, by = "COD_MUN") #junta os dados
    
    if (input$ordem == "Municipio") {
      joinedDataset@data <- merge(joinedDataset@data, nomes, by="COD_MUN", all=TRUE) #atribui os nomes
      joinedDataset@data <- joinedDataset@data[c(1, 6, 2, 3, 4, 5)]
    }
    
    # print(head(joinedDataset@data))
    print(isS4(joinedDataset))
    joinedDataset
  })
  
  #só chamar uma vez
  output$spMap<-renderLeaflet({
    
    leaflet() %>%
      addTiles() %>%
      
      #centraliza o mapa
      setView(mean(bounds[1,]),
              mean(bounds[2,]),
              zoom=7 #quase todo o estado de SP
      )       
    
  })
  
  
  
  observe({
    theData<-getDataSet()
    print("theData")
    print(head(theData@data))
    
    #cor da palheta
    pal <- colorQuantile("YlOrRd", theData$Valor, n = 10) 
    
    #texto de popup
    borough_popup <- paste0("<strong>", input$ordem, ": </strong>", 
                            theData$Nome, 
                            "<br><strong>",
                            input$Indicador, input$indicador, " em ", as.character(input$selecAno), "
                            : </strong>", 
                            formatC(theData$Valor, big.mark=',')
    )
    
    #quando os dados mudam, os polígonos são redesenhados, mas o mapa de fundo, não
    leafletProxy("spMap", data = theData) %>%
      clearShapes() %>%
      addPolygons(data = theData,
                  fillColor = pal(theData$Valor), 
                  fillOpacity = 0.8, 
                  color = "#BDBDC3", 
                  weight = 2,
                  popup = borough_popup)  
    
  })
  
  #tabela de resultados
  output$spTable <- renderDataTable(datatable({
    dataSet<-getDataSet()
    dataSet<-dataSet@data[,c(2,4)] #apenas nome e valor
    names(dataSet)<-c(as.character(input$ordem),paste0(input$Indicador," ", as.character(input$indicador)) )
    dataSet
  },
  options = list(lengthMenu = c(5, 10, 33), pageLength = 5))
  )
  
  #seletor de anos, baseado nos anos disponíveis
  output$selecAno<-renderUI({
    yearRange<-sort(unique(as.numeric(as.character(dados_sp$Ano))), decreasing=TRUE)
    selectInput("selecAno", "Ano", choices=yearRange, selected=yearRange[1])
  })
}