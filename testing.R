setwd("/home/joao/Documents/TCC/SP-Leaflet-Try/")

mortalidade_2017 <- read.csv("mortalidade_2017.csv")
mortalidade_2016 <- read.csv("mortalidade_2016.csv")
consultas_2017 <- read.csv("consultas_media_2017.csv")
consultas_2016 <- read.csv("consultas_media_2016.csv")
nomes <-read.csv("nomes.csv")
nomes <- reduceorder(nomes, 1)
colnames(nomes) <- c("COD_MUN", "Nome")
merged <- rbind(mortalidade_2017, mortalidade_2016, consultas_2017, consultas_2016)
head(merged, n=20)
head(nomes)
tail(merged)
#merged <- merge(merged, nomes, by="COD_MUN")

merged$COD_MUN <- as.factor(merged$COD_MUN)
merged$Ano <- as.factor(merged$Ano)
merged$Valor <- as.numeric(sub(",", ".", as.character(merged$Valor), fixed = TRUE))
merged$Indicador <- as.factor(merged$Indicador)


summary(merged)

merged[c(1,2)]
