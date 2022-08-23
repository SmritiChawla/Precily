##Loading libraries
library(keras)
library(impute)
library(tidyverse)
library(ggplot2)
library(ggridges)

##Source function
source("DrugsPred.R")

##loading data
load("enrichment.scores.Rdata")

##loading metadata
load("GDSC2_metadata.RData")

##Drug response prediction
df1 = drugPred(enrichment.scores,metadata,"PRAD")

##Reduce list to dataframe
Pred=df1 %>% purrr::reduce(left_join, by = "DRUGS")
Predictions = Pred[,2:ncol(Pred)]
rownames(Predictions) = Pred[,1]
colnames(Predictions)<-gsub('FBS.','',colnames(Predictions))

####converting LN IC50 to zscores
sdmean = read.csv("Drugs_mean_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,Predictions,by=0)
Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
rownames(Predictions) = pred[,1]

##Ridegplot
df = reshape2::melt(Predictions)
df$variable = gsub("\\..*","",df$variable)

df %>%
  ggplot( aes(y=reorder(variable,value), x=value,  fill=variable)) +
  geom_density_ridges_gradient() +
  theme_classic(base_size = 20) + scale_fill_manual( values=c("DU145"="#A6CEE3","LNCAP"="#1F78B4","PC3"="#B2DF8A","DUCAP"="#33A02C","VCAP"="#FB9A99")) +ylab("Samples")
