library(shinydashboard)
library(leaflet)
library(DT)

header<-dashboardHeader(title="Indicadores de Saúde em São Paulo")

body<-dashboardBody(
  fluidRow(
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("spMap", height=400)
           ),
           box(width=NULL,
               dataTableOutput("spTable")
           )
    ),
    column(width=3,
           box(width=NULL, 
               uiOutput("selecAno"),
               radioButtons("indicador", "Indicador",c("Mortalidade Infantil"="Mortalidade", "Consultas Médias"="Consultas"))
               
           )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)