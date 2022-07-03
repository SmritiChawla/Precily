##loading libraries
library(ggplot2)


##loading data
load("enrichment.scores.Rdata")
colnames(enrichment.scores)<-gsub('FBS.','',colnames(enrichment.scores))

##subsetting mTOR related pathways
mtor = enrichment.scores[rownames(enrichment.scores)[grep('MTOR',rownames(enrichment.scores))],]
mtor1 = cbind.data.frame(rownames(mtor),mtor)
rownames(mtor1) = NULL
colnames(mtor1)[1] = "Pathways" 

final = melt(mtor1)
final$variable<-gsub('FBS.','',final$variable)
final$variable = gsub("\\..*","",final$variable)
final$variable <- factor(final$variable,
                         levels = c('LNCAP','DUCAP',"VCAP","DU145","PC3"),ordered = TRUE)


ggplot(final, aes(x=variable, y=value,col=variable))+   geom_point(position=position_jitter(width=0.15, height=0.0,seed=1),size=3,alpha=1)+
  geom_boxplot(lwd=0.4,fatten=2,alpha=0.2,outlier.shape=NA)+theme_classic(base_size = 30) + theme(axis.text.x = element_text(angle = 45, hjust=1,size=15),axis.text.y = element_text(size=15)) + scale_color_manual( values=c("DU145"="#A6CEE3","LNCAP"="#1F78B4","PC3"="#B2DF8A","DUCAP"="#33A02C","VCAP"="#FB9A99"))


###Wilcoxon
LNCAP = final[which(final$variable=="LNCAP"),]
DU145 = final[which(final$variable=="DUCAP"),]
PC3 = final[which(final$variable=="PC3"),]
DUCAP = final[which(final$variable=="DU145"),]
VCAP = final[which(final$variable=="VCAP"),]

wilcox.test(LNCAP$value,DUCAP$value)
wilcox.test(LNCAP$value,VCAP$value)
wilcox.test(LNCAP$value,DU145$value)
wilcox.test(LNCAP$value,PC3$value)
