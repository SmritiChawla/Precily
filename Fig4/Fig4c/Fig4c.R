##loading libraries
library(ggplot2)

##loading predictions
Predictions = read.csv("ATTX_predictions.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1,check.names = F)

##Converting predictions into z-scores
sdmean = read.csv("Drugs_means_sd.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
pred = merge(sdmean,Predictions,by=0)
Predictions = (pred[,5:ncol(pred)] - pred[,3])/pred[,4]
rownames(Predictions) = pred[,1]


##loading metadata
metadata = read.csv("Metadata.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1,check.names = F)

pred = t(Predictions)

df = merge(pred,metadata,by=0)
mat = reshape2::melt(df)

##plotting
p <- ggplot(mat, aes(x=Clusters, y=value,col=Clusters)) + 
  geom_boxplot(outlier.shape = NA)
p +theme_classic(base_size = 20) +scale_color_manual(values=c(Cluster1="mediumorchid1",Cluster2="deeppink",Cluster3="royalblue1"))+theme(axis.text.x = element_text(angle = 45, hjust=1))+
ylab("Predicted IC50")
                                                                                                                                                                                                  

###Wilcoxon Rank Sum test 
Cluster1 = mat[which(mat$Clusters== "Cluster1"),]
Cluster2 = mat[which(mat$Clusters== "Cluster2"),]
Cluster3 = mat[which(mat$Clusters== "Cluster3"),]

wilcox.test(Cluster1$value,Cluster2$value)
wilcox.test(Cluster2$value,Cluster3$value)
wilcox.test(Cluster1$value,Cluster3$value)

