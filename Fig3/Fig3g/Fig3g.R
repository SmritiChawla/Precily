##Loading libraries
library(keras)
library(impute)
library(tidyverse)
library(pheatmap)
library(ggpubr)


##source function
source("DrugsPred.R")

##loading data
load("enrichment.scores.Rdata")

##loading metadata
load("GDSC2_metadata.RData")

drugs = read.table("SMILES.csv",sep=",",header=F,stringsAsFactors = F,row.names = 1)


##Predictions
df1 = drugPred(enrichment.scores,metadata,"PRAD")
Exp_drugs = do.call(rbind,df1)
colnames(Exp_drugs) = rownames(drugs)
