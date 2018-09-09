getData <- function() {
  mortalidade_2017 <- read.csv("mortalidade_2017.csv")
  mortalidade_2016 <- read.csv("mortalidade_2016.csv")
  consultas_2017 <- read.csv("consultas_media_2017.csv")
  consultas_2016 <- read.csv("consultas_media_2016.csv")
  nomes <-read.csv("nomes.csv")
  nomes <- reduceorder(nomes, 1)
  colnames(nomes) <- c("COD_MUN", "Nome")
  merged <- rbind(mortalidade_2017, mortalidade_2016, consultas_2017, consultas_2016)
  #merged <- merge(nomes, merged, by="COD_MUN", all=TRUE)
  
  merged$COD_MUN <- as.factor(merged$COD_MUN)
  merged$Ano <- as.factor(merged$Ano)
  merged$Valor <- as.numeric(sub(",", ".", as.character(merged$Valor), fixed = TRUE))
  merged$Indicador <- as.factor(merged$Indicador)
  merged$GeoType <- as.factor(merged$GeoType)
  
  return (merged)
}