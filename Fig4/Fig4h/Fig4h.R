##load libraries
library(impute)
library(keras)
library(pheatmap)

##source function
source("DrugsPred.R")

##load enrichment scores
load("enrichment.scores.Rdata")

##loading metadata file
load("GDSC2_metadata.RData")
drugs = read.table("Unseendrugs.csv",sep=",",header=F,stringsAsFactors = F,row.names = 1)

##Predictions
df1 = drugPred(enrichment.scores,metadata,"PRAD")
unseen = do.call(rbind,df1)
rownames(unseen) = colnames(enrichment.scores)
colnames(unseen) = rownames(drugs)
df = t(unseen)

##Loading metadata files
meta = read.csv("Metadata.csv",sep=",",row.names=1,stringsAsFactors = F,header=T)
meta1 = meta[colnames(df),]

##processing of data for plotting heatmap
ann_colors = list(
  Clusters = c(Cluster1="mediumorchid1",Cluster2="deeppink",Cluster3="royalblue1"),
  Samples = c("PRE-CX"="#984EA3","POST-CX"="#FF7F00",CRPC="#E41A1C",ENZS="#4DAF4A",ENZR="#377EB8"))

cols = colorRampPalette(c("blue", "white","grey20"))(100)

pos1 = which(meta1$Samples=="PRE-CX")
pos2 = which(meta1$Samples=="POST-CX")
pos3 = which(meta1$Samples=="CRPC")
pos4 = which(meta1$Samples=="ENZS")
pos5 = which(meta1$Samples=="ENZR")

df = df[,c(pos1,pos2,pos3,pos4,pos5)]
meta1 = meta1[colnames(df),]
colnames(df)<-sub("ATTX.","",colnames(df))
rownames(meta1) = colnames(df)

pheatmap(df,fontsize_col = 7,col= cols,angle_col = 45,fontsize_row = 10,cluster_cols = F,annotation_colors = ann_colors,cluster_rows=F,annotation_col  = meta1,annotation_names_row = F,clustering_distance_rows = "euclidean",
         clustering_distance_cols = "euclidean",cellheight = 15,cellwidth = 9,scale="row")

