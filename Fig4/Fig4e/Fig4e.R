##loading libraries
library(ggridges)
library(ggplot2)

##loading predictions
predictions = read.csv("ATTX_predictions.csv",sep=",",header = T,stringsAsFactors = F,check.names = F,row.names = 1)

##Converting predictions into z-score
sdmean = read.csv("Drugs_means_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,predictions,by=0)
Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
Predictions=cbind.data.frame(pred[,1],Predictions)
pred = reshape2::melt(Predictions)

##loading metadata
metadata = read.csv("Metadata.csv",sep=",",header = T,stringsAsFactors = F,check.names = F)
colnames(metadata)[1] = "variable"

##Preparing data for plotting
df1 = merge(pred,metadata,by="variable")
df1$Type <- factor(df1$Type, levels = c("PRE-CX", "POST-CX","CRPC","ENZS" ,"ENZR"))


df1 %>%
  ggplot( aes(y=Type, x=value,  fill=Type)) +
  geom_density_ridges_gradient() +
  theme_classic(base_size = 20) + scale_fill_manual( values=c("PRE-CX"="#984EA3","POST-CX"="#FF7F00",CRPC="#E41A1C",ENZS="#4DAF4A",ENZR="#377EB8")) +xlab("Predicted value")
