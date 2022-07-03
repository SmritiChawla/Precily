##loading libraries
library(ggplot2)

##loading enrichment scores
load("enrichment.scores.Rdata")

##Subsetting data using proliferation related pathways
pathways = c("KEGG_RIBOSOME","KEGG_DNA_REPLICATION","REACTOME_TRANSLATION","REACTOME_PEPTIDE_CHAIN_ELONGATION","REACTOME_CYCLIN_E_ASSOCIATED_EVENTS_DURING_G1_S_TRANSITION_","REACTOME_M_G1_TRANSITION","REACTOME_G1_S_TRANSITION","REACTOME_CYCLIN_A_B1_ASSOCIATED_EVENTS_DURING_G2_M_TRANSITION","REACTOME_CDT1_ASSOCIATION_WITH_THE_CDC6_ORC_ORIGIN_COMPLEX","REACTOME_SYNTHESIS_OF_DNA","REACTOME_ASSEMBLY_OF_THE_PRE_REPLICATIVE_COMPLEX","REACTOME_S_PHASE")

pos = which(rownames(enrichment.scores) %in% pathways)
mat = enrichment.scores[pos,]

df1 = cbind.data.frame(rownames(mat),mat)
rownames(df1) = NULL
colnames(df1)[1] = "Pathways" 


##loading metadata
metadata = read.csv("Metadata.csv",sep=",",header = T,stringsAsFactors = F)
colnames(metadata)[1] ="variable"


##Processing of data for plotting
df2 = reshape2::melt(df1)
df3 = merge(df2,metadata,by="variable")
ggplot(df3, aes(x=Clusters, y=value,col=Clusters))+ 
  geom_boxplot(lwd=0.4,fatten=2,alpha=0.2,outlier.shape=NA)+ scale_color_manual(values=c(Cluster1="mediumorchid1",Cluster2="deeppink",Cluster3="royalblue1"))+theme_classic(base_size = 20)+theme(axis.text.x = element_text(angle = 45, hjust=1))+ylab("GSVA scores (Proliferation pathways)") 


###Wilcoxon Rank Sum test 
Cluster1 = df3[which(df3$Clusters== "Cluster1"),]
Cluster2 = df3[which(df3$Clusters== "Cluster2"),]
Cluster3 = df3[which(df3$Clusters== "Cluster3"),]

wilcox.test(Cluster1$value,Cluster2$value)
wilcox.test(Cluster2$value,Cluster3$value)
wilcox.test(Cluster1$value,Cluster3$value)
