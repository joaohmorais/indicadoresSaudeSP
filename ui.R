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
               selectInput("indicador", label = "Indicador", choices = c("Mortalidade Infantil"="Mortalidade", "Consultas Médias"="Consultas")),
               radioButtons("ordem", label = "Mostrar por",
                            choices = list("Município" = "Municipio", "DRS" = "drs", "Região de Saúde" = "reg_saude", "RRAS" = "RRAS"))
               
           )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = FALSE),
  body
)