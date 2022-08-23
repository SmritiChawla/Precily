##loading libraries
library(ggplot2)

##loading predictions
predictions = read.csv("ATTX_predictions.csv",sep=",",header = T,stringsAsFactors = F,check.names = F,row.names = 1)

##Converting predictions into z-scores
sdmean = read.csv("Drugs_means_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,predictions,by=0)
Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
rownames(Predictions) = pred[,1]

##Extracting EGFR inhibitors
pos = which(rownames(Predictions) %in% c("Afatinib","AZD3759","Erlotinib","Gefitinib","Lapatinib","Osimertinib","Sapitinib"))
Predictions = Predictions[pos,]
pred = reshape2::melt(Predictions)

##loading metadata
metadata = read.csv("Metadata.csv",sep=",",header = T,stringsAsFactors = F)
colnames(metadata)[1] = "variable"

##Preparing data
df = merge(pred,metadata,by="variable")
df$Type <- factor(df$Type, levels = c("PRE-CX", "POST-CX","CRPC","ENZS" ,"ENZR"))

##plotting
ggplot(df, aes(x=Type, y=value,col=Type)) + 
  geom_boxplot(outlier.shape = NA)+scale_color_manual(values=c("PRE-CX"="#984EA3","POST-CX"="#FF7F00",CRPC="#E41A1C",ENZS="#4DAF4A",ENZR="#377EB8"))+theme_classic(base_size = 15)+theme(axis.text.x = element_text(angle = 45, hjust=1))+ylab("Predicted  LN IC50 (Z-score)")

