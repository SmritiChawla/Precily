##loading libraries
library(keras)
library(GSEABase)
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
cluster1_ave = expAve1

expAve2 = as.matrix(apply(Stress,1,mean))
cluster2_ave = expAve2

expAve3 = as.matrix(apply(Drug,1,mean))
cluster3_ave = expAve3

df = cbind(cluster1_ave,cluster2_ave,cluster3_ave)
##Running GSVA
geneSets = getGmt("c2.cp.v6.1.symbols.gmt")
enrichment.scores <- gsva(df, geneSets, method="gsva")
colnames(enrichment.scores) = c("Untreated","Stressed","Drugtolerant")


##loading metadata file
load("GDSC2_metadata.RData")

##Making predictions
df1 = drugPred(enrichment.scores,metadata,"BRCA")


###barplot
d1 = c(-1.1604,-4.8086)
d1 = as.data.frame(d1)
d1 = t(d1)
colnames(d1) = c("Untreated","Sensitive")
d=reshape2::melt(d1)
colnames(d)[2] = "Type" 

g=ggbarplot(d, x = "Type", y = "value",
          fill = "Type",               # change fill color by cyl
          color = "white",            # Set bar border colors to white
          palette = c("red","darkgreen"),            # jco journal color palett. see ?ggpar
          sort.val = "desc",          # Sort the value in dscending order
          sort.by.groups = FALSE,     # Don't sort inside each group
          x.text.angle = 45          # Rotate vertically x axis texts
) 
g+ylab("Predicted Value")+xlab("")
