##Loading libraries
library(keras)
library(impute)
library(pheatmap)
library(tidyverse)

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

####converting LN IC50 to zscores
sdmean = read.csv("Drugs_mean_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,Predictions,by=0)
Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
rownames(Predictions) = pred[,1]

###Processing data
pathways = read.csv("GDSC2_pathway_targets.csv",sep=",",header = T,stringsAsFactors = F)
pos = which(pathways$X %in% rownames(Predictions))
pathways = unique(pathways[pos,c(1,3)])
rownames(pathways) = pathways[,1]
ann_row1 = merge(pathways,Predictions,by=0)
ann_row1= ann_row1[order(ann_row1$PATHWAY_NAME), , drop = FALSE]

mat = ann_row1[,4:ncol(ann_row1)]
rownames(mat) = ann_row1[,1]
ann_row = as.data.frame(ann_row1[,c(3)])
rownames(ann_row) = ann_row1[,1]
colnames(ann_row) = "Pathways"
ann_row$Pathways = as.factor(ann_row$Pathways)
ann_row$Pathways <- ifelse(ann_row$Pathways=="PI3K/MTOR signaling", "PI3K/MTOR signaling", NA)
sample.types<-sub("FBS.","",colnames(mat))
sample.types<-factor(sub("\\..*","",sample.types))

labels = as.data.frame((sample.types))
rownames(labels) = colnames(mat)
colnames(labels)[1] = "Celllines"
labels$Celllines = as.factor(labels$Celllines)
rownames(labels)<-sub("FBS.","",rownames(labels))
ann_colors = list(
  Celllines = c("DU145"="#A6CEE3","LNCAP"="#1F78B4","PC3"="#B2DF8A","DUCAP"="#33A02C","VCAP"="#FB9A99"),
  Pathways=c("PI3K/MTOR signaling" = "#FD00E2")
             
)
colnames(mat)<-sub("FBS.","",colnames(mat))

####Plotting heatmap
pheatmap(mat,fontsize_col = 8,col= rev(hcl.colors(20, "Spectral")),angle_col = 45,fontsize_row = 10,cluster_cols = T,annotation_colors = ann_colors,cluster_rows=F,annotation_col = labels,annotation_names_row = F,clustering_distance_rows = "euclidean",
         clustering_distance_cols = "euclidean" ,show_rownames = F,fontsize = 8,cellwidth = 15,cellheight = 2,annotation_row = ann_row)
