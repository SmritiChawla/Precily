##loading libraries
library(readxl)
library(GSEABase)
library(GSVA)
library(h2o)
library(data.table)
library(impute)
library(ggplot2)
h2o.init()

##Source function for drug response prediction
source("DrugsPred.R")

##loading data
data = read_excel("GSE77940_pre_post_melanoma.xlsx")
df = as.matrix(data[,3:ncol(data)])
rownames(df) = as.matrix(data[,2])

##Convert rpkm data to tpm
rpkm2tpm <- function(x) {
  x <- as.matrix(x)
  return(t(t(x)/colSums(x))*10^6)
}

tpm = rpkm2tpm(df)

##log transform tpm data
mat = log2(tpm+1)

##convert data to gsva
geneSets = getGmt("c2.cp.v6.1.symbols.gmt")
enrichment.scores <- gsva(mat, geneSets, method="gsva")

##loading AutoML model
path = " " ##path to model
model1 <- h2o.loadModel(path= path)


##loading TCGA metadata file
load("metadata_TCGA.RData")

##Predictions
pred = drugPred(enrichment.scores,metadata,"SKCM")

##Patient1 pre
pos1 = which(pred[[1]][,1]=="Dabrafenib")
pos2 = which(pred[[1]][,1]=="Trametinib")
dabra_pre = pred[[1]][pos1,]
tra_pre = pred[[1]][pos2,]

##patient1 post
pos1 = which(pred[[2]][,1]=="Dabrafenib")
pos2 = which(pred[[2]][,1]=="Trametinib")
dabra_post = pred[[2]][pos1,]
tra_post = pred[[2]][pos2,]

##barplot Patient1 
pt1 = cbind(rbind.data.frame(dabra_pre,tra_pre,dabra_post,tra_post),c("Pre","Pre","Post","Post"))
colnames(pt1) = c("Drugs","Probability","Group")
pt1$Group <- factor(pt1$Group, levels = c("Pre","Post"))

ggplot(data=pt1, aes(x=Group, y=Probability, fill=Drugs)) +
  geom_bar(stat="identity", color="black", position=position_dodge(),width = 0.6)+
  theme_classic(base_size=20) + ylab("Probability of response")+scale_fill_manual(values=c(Dabrafenib="red",Trametinib="darkslateblue"))



##Patient2 pre
pos1 = which(pred[[3]][,1]=="Dabrafenib")
pos2 = which(pred[[3]][,1]=="Trametinib")
dabra_pre = pred[[3]][pos1,]
tra_pre = pred[[3]][pos2,]

##patient2 post
pos1 = which(pred[[4]][,1]=="Dabrafenib")
pos2 = which(pred[[4]][,1]=="Trametinib")
dabra_post = pred[[4]][pos1,]
tra_post = pred[[4]][pos2,]

##barplot Patient2 
pt1 = cbind(rbind.data.frame(dabra_pre,tra_pre,dabra_post,tra_post),c("Pre","Pre","Post","Post"))
colnames(pt1) = c("Drugs","Probability","Group")
pt1$Group <- factor(pt1$Group, levels = c("Pre","Post"))

ggplot(data=pt1, aes(x=Group, y=Probability, fill=Drugs)) +
  geom_bar(stat="identity", color="black", position=position_dodge(),width = 0.6)+
  theme_classic(base_size=20) + ylab("Probability of response")+scale_fill_manual(values=c(Dabrafenib="red",Trametinib="darkslateblue"))


##Patient3 pre
pos1 = which(pred[[5]][,1]=="Dabrafenib")
pos2 = which(pred[[5]][,1]=="Trametinib")
dabra_pre = pred[[5]][pos1,]
tra_pre = pred[[5]][pos2,]

##patient3 post
pos1 = which(pred[[6]][,1]=="Dabrafenib")
pos2 = which(pred[[6]][,1]=="Trametinib")
dabra_post = pred[[6]][pos1,]
tra_post = pred[[6]][pos2,]

##barplot Patient3 
pt1 = cbind(rbind.data.frame(dabra_pre,tra_pre,dabra_post,tra_post),c("Pre","Pre","Post","Post"))
colnames(pt1) = c("Drugs","Probability","Group")
pt1$Group <- factor(pt1$Group, levels = c("Pre","Post"))

ggplot(data=pt1, aes(x=Group, y=Probability, fill=Drugs)) +
  geom_bar(stat="identity", color="black", position=position_dodge(),width = 0.6)+
  theme_classic(base_size=20) + ylab("Probability of response")+scale_fill_manual(values=c(Dabrafenib="red",Trametinib="darkslateblue"))

