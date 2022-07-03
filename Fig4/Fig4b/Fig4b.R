setwd("D:\\PrecOnco_codes_figurewise\\Fig3\\Fig3b")

##loading libraries
library(GSVA)
library(GSEABase)
library(impute)
library(tidyverse)
library(keras)
library(umap)
library(ggplot2)


##loading Predictions
Predictions = read.csv("ATTX_predictions.csv",sep=",",header=T,stringsAsFactors = F,row.names = 1,check.names = F)


##loading metadata
labels = read.csv("Metadata.csv",sep=",",header = T,row.names = 1)
labels = labels[colnames(Predictions),]

##UMAP
PCA_Res = prcomp(t(Predictions),scale = T, center = T)
##UMAP
set.seed(6)
um = umap(PCA_Res$x[,1:10],n_neighbors = 5)


df1 = cbind.data.frame(um$layout,labels$Samples)
colnames(df1) = c("UMAP1","UMAP2","Samples")
df1$Samples = as.factor(df1$Samples)

df1$Samples <- factor(df1$Samples, levels = c("PRE-CX", "POST-CX","CRPC", "ENZS","ENZR"))
ggplot(df1,aes(x = UMAP1, y = UMAP2)) +
  geom_point(aes(color = Samples),size=4) + theme_classic(base_size = 20)+scale_color_manual(values=c("PRE-CX"="#984EA3","POST-CX"="#FF7F00",CRPC="#E41A1C",ENZS="#4DAF4A",ENZR="#377EB8")) + guides(colour = guide_legend(override.aes = list(size=4)))


