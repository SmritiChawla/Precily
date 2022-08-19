##Loading libraries
library(keras)
library(impute)
library(tidyverse)
library(ggplot2)
library(reshape2)

##Source function
source("DrugsPred.R")

##loading data
load("enrichment.scores.Rdata")
colnames(enrichment.scores)<-gsub('FBS.','',colnames(enrichment.scores))

##loading metadata
load("GDSC2_metadata.RData")

##Drug response prediction
df1 = drugPred(enrichment.scores,metadata,"PRAD")
##Reduce list to dataframe
Pred=df1 %>% purrr::reduce(left_join, by = "DRUGS")
rownames(Pred) = Pred[,1]
predictions = Pred[,-1]

##Convert IC50 to Z-scores
sdmean = read.csv("Drugs_means_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,predictions,by=0)
Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
Pred = cbind.data.frame(pred[,1],Predictions)

###Subsetting PI3K/MTOR signaling drugs
pathways = read.csv("GDSC2_targeted_pathways.csv",sep=",",header = T,stringsAsFactors = F)
pos = which((pathways[,1]) %in% Pred[,1])
pathways=pathways[pos,]
pos = which(pathways$Pathways =="PI3K/MTOR signaling")
pathways = pathways[pos,]

dr = as.vector(pathways[,1])
pos = which(Pred[,1] %in% dr)
mat = Pred[pos,]

##data preparation
final = melt(mat)
colnames(final)[1] = "DRUGS"

final$variable<-gsub('ATT.','',final$variable)
final$col <- ifelse(final$DRUGS %in% c("AZD2014"), "darkred", "ivory4") 
final <- within(final, col[DRUGS == c("Afuresertib")] <- "Pink")
final <- within(final, col[DRUGS == c("Ipatasertib")] <- "Pink")
final <- within(final, col[DRUGS == c("Uprosertib")] <- "Pink")
final$shape <- ifelse(final$DRUGS == "AZD2014",17,19) 
final <- within(final, shape[DRUGS == c("Ipatasertib")] <- 15 )
final <- within(final, shape[DRUGS == c("Afuresertib")] <- 23 )
final <- within(final, shape[DRUGS == c("Uprosertib")] <- 24 )
shape = as.numeric(final$shape)
names(shape) = final$DRUGS
final$variable = gsub("\\..*","",final$variable)
final$variable <- factor(final$variable,
                         levels = c('LNCAP','DUCAP',"VCAP","DU145","PC3"),ordered = TRUE)

##Ploting
ggplot(final, aes(x=variable, y=value))+ 
  geom_boxplot(lwd=0.3,fatten=4,alpha=0.2,outlier.shape=NA)+ 
  geom_point(aes(color=col,shape= DRUGS), position=position_jitter(width=0.15, height=0.0,seed=1),size=1,alpha=0.8,stroke=1)+ scale_shape_manual(values =shape)+
  scale_colour_identity()+ 
  theme_classic(base_size = 20) + theme(axis.text.x = element_text(angle = 45, hjust=1,size=10),axis.text.y = element_text(size=10))


