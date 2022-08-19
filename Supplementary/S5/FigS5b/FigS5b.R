##loading libraries
library(ggplot2)

##loading predictions
##loading predictions
predictions = read.csv("ATTX_predictions.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1,check.names = F)

##loading metadata
metadata = read.csv("Metadata.csv",sep=",",header = T,stringsAsFactors = F)
colnames(metadata)[1] = "variable"

##Converting LN IC50 to z-scores
sdmean = read.csv("Drugs_means_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,predictions,by=0)
 Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
rownames(Predictions) = pred[,1]
 
pos = which(rownames(Predictions) %in% "Sapitinib")
Predictions = Predictions[pos,]
pred = reshape2::melt(Predictions)

##Preparing data
df = merge(pred,metadata,by="variable")
df$Samples <- factor(df$Samples, levels = c("PRE-CX", "POST-CX","CRPC","ENZS" ,"ENZR"))
ggplot(df, aes(x=Samples, y=value,col=Samples)) + 
  geom_boxplot(outlier.shape = NA)+scale_color_manual( values=c(CRPC="#E41A1C",ENZR="#377EB8",ENZS="#4DAF4A","PRE-CX"="#984EA3","POST-CX"="#FF7F00"))+theme_classic(base_size = 20)+theme(axis.text.x = element_text(angle = 45, hjust=1))+ylab("Predicted  LN IC50 (Z-score)")
