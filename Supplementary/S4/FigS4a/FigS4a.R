##Loading libraries
library(keras)
library(impute)
library(tidyverse)
library(reshape2)
library(ggridges)
library(ggplot2)

##source function
source("DrugsPred.R")

##loading data
load("enrichment.scores.Rdata")

##Aveeraging GSVA scores of biological replicates
enrichment.scores =t(apply(enrichment.scores, 1, function(x) tapply(x, colnames(enrichment.scores), mean)))

##loading metadata file
load("GDSC2_metadata.RData")

##Drug response prediction
df1 = drugPred(enrichment.scores,metadata,"PRAD")

##Reduce list to dataframe
Pred=df1 %>% purrr::reduce(left_join, by = "DRUGS")
rownames(Pred) = Pred[,1]
predictions = Pred[,-1]

sdmean = read.csv("Drugs_means_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,predictions,by=0)
Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
Pred = cbind.data.frame(pred[,1],Predictions)
colnames(Pred)<-sub("ATT.","",colnames(Pred))

##Ridgeplot
df = reshape2::melt(Pred)
df$variable <- factor(df$variable, levels = c("DHT", "APA.DHT", "BIC.DHT","ENZ.DHT","VEH","APA.VEH","BIC.VEH","ENZ.VEH"))


df %>%
  ggplot( aes(y=variable, x=value,  fill=variable)) +
  geom_density_ridges_gradient() +
  theme_classic(base_size = 25) + scale_fill_manual( values=c("DHT"="#99000D","BIC.DHT"="#FB6A4A","ENZ.DHT"="#FC9272","APA.DHT"="#EF3B2C","VEH"="#084594","BIC.VEH"="#4292C6","ENZ.VEH"="#9ECAE1","APA.VEH"="#2171B5"))
