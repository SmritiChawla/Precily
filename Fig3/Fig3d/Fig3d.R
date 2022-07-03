##Loading libraries
library(keras)
library(impute)
library(tidyverse)
library(pheatmap)


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
Predictions = Pred[,2:ncol(Pred)]
rownames(Predictions) = Pred[,1]


####converting IC50 to zscores
sdmean = read.csv("Drugs_mean_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,Predictions,by=0)
Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
rownames(Predictions) = pred[,1]

###Plotting heatmap
sample.types<-sub("ATT.","",colnames(Predictions))
labels = as.data.frame((sample.types))
rownames(labels) = colnames(Predictions)
colnames(labels)[1] = "Samples"
labels$Samples = as.factor(labels$Samples)
labels$Samples <- factor(labels$Samples, levels = c("DHT", "APA.DHT", "BIC.DHT","ENZ.DHT","VEH","APA.VEH","BIC.VEH","ENZ.VEH"))
ann_colors = list(
  Samples = c("DHT"="#99000D","BIC.DHT"="#FB6A4A","ENZ.DHT"="#FC9272","APA.DHT"="#EF3B2C","VEH"="#084594","BIC.VEH"="#4292C6","ENZ.VEH"="#9ECAE1","APA.VEH"="#2171B5"))
rownames(labels) = sample.types
colnames(Predictions) = sample.types

pheatmap(Predictions,fontsize_col = 8,col= rev(hcl.colors(20, "Spectral")),angle_col = 45,fontsize_row = 8,cluster_cols = T,annotation_colors = ann_colors,cluster_rows=T,annotation_col = labels,annotation_names_row = F,clustering_distance_rows = "euclidean",
         clustering_distance_cols = "euclidean" ,show_rownames = F,fontsize = 8,cellwidth = 20,cellheight = 2)






