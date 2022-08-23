##Loading libraries
library(keras)
library(impute)
library(tidyverse)
library(ggpubr)

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

##Extract original labels of LNCaP cell line
pos = which(metadata$CELL_LINE_NAME=="LNCAPCLONEFGC")
meta = metadata[pos,]

###Scatter plots
LNCAP_gdsc = cbind.data.frame(meta$DRUG_NAME,meta$LN_IC50)
colnames(LNCAP_gdsc)[1] = "DRUGS"

##LNCAP1
LNCAP1 = Pred[,c(1,4)]
mat1 = merge(LNCAP_gdsc,LNCAP1,by="DRUGS")
colnames(mat1) = c("DRUGS","Real","Predicted")

##LNCAP2
mat2 = Pred[,c(1,5)]
mat2 = merge(LNCAP_gdsc,mat2,by="DRUGS")
colnames(mat2) = c("DRUGS","Real","Predicted")

###Scatter plot
group = c(rep("LNCAP.1",154),rep("LNCAP.2",154))

df = rbind.data.frame(mat1,mat2)
df1 = cbind(df,group)

ggscatter(df1, x = "Real", y = "Predicted",
          add = "reg.line",                         
          conf.int = TRUE,cor.coef.size = 5 ,                        
          color = "group", palette = c("red","blue"),           
          shape = "group"                       
)+stat_cor(aes(color = group))  


