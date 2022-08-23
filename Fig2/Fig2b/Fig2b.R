##loading libraries
library(keras)
library(ggpubr)
library(GSVA)
library(impute)

##Source function for drug response prediction
source("DrugsPred.R")

##Load tpm gene expression matrix
load("SRP040309_log_tpm.Rdata")

##Extracting samples to make predictions
untreat = df1[,1:5]
Stress = df1[,6:10]
Drug = df1[,11:15]

##average gene expression of cells of same type
expAve1 = as.matrix(apply(untreat,1,mean))
expAve2 = as.matrix(apply(Stress,1,mean))
expAve3 = as.matrix(apply(Drug,1,mean))

df = cbind(expAve1,expAve2,expAve3)
##Running GSVA
geneSets = getGmt("c2.cp.v6.1.symbols.gmt")
enrichment.scores <- gsva(df, geneSets, method="gsva")
colnames(enrichment.scores) = c("Untreated","Stressed","Drugtolerant")

##loading metadata file
load("GDSC2_metadata.RData")

##Making predictions
df1 = drugPred(enrichment.scores,metadata,"BRCA")

##Extract predicted values for Paclitaxel drugs
Untreated = df1[[1]][which(df1[[1]][,1] == "Paclitaxel"),2]
Sensitive = df1[[3]][which(df1[[3]][,1] == "Paclitaxel"),2]

###barplot
d1 = c(Untreated,Sensitive)
d1 = as.data.frame(d1)
d1 = t(d1)
colnames(d1) = c("Untreated","Sensitive")
d=reshape2::melt(d1)
colnames(d)[2] = "Type" 

g=ggbarplot(d, x = "Type", y = "value",
          fill = "Type",               
          color = "white",            
          palette = c("red","darkgreen"),            
          sort.val = "desc",          
          sort.by.groups = FALSE,     
          x.text.angle = 45          
) 
g+ylab("Predicted LN IC50")+xlab("")
