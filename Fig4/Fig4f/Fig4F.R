##loading libraries
library(ggplot2)

##loading enrichment scores
enrichment.scores = read.csv("ATTX_GSVA_scores.csv",sep=",",stringsAsFactors = F,row.names = 1,check.names = F)


##Subsetting data using proliferation related pathways
pathways = c("KEGG_RIBOSOME","KEGG_DNA_REPLICATION","REACTOME_TRANSLATION","REACTOME_PEPTIDE_CHAIN_ELONGATION","REACTOME_CYCLIN_E_ASSOCIATED_EVENTS_DURING_G1_S_TRANSITION_","REACTOME_M_G1_TRANSITION","REACTOME_G1_S_TRANSITION","REACTOME_CYCLIN_A_B1_ASSOCIATED_EVENTS_DURING_G2_M_TRANSITION","REACTOME_CDT1_ASSOCIATION_WITH_THE_CDC6_ORC_ORIGIN_COMPLEX","REACTOME_SYNTHESIS_OF_DNA","REACTOME_ASSEMBLY_OF_THE_PRE_REPLICATIVE_COMPLEX","REACTOME_S_PHASE")
pos = which(rownames(enrichment.scores) %in% pathways)
mat = enrichment.scores[pos,]

df1 = cbind.data.frame(rownames(mat),mat)
rownames(df1) = NULL
colnames(df1)[1] = "Pathways" 


##loading metadata
metadata = read.csv("Metadata_with_clusters.csv",sep=",",header = T,stringsAsFactors = F,check.names = F)
colnames(metadata)[1] ="variable"



##Processing of data for plotting
df2 = reshape2::melt(df1)
df3 = merge(df2,metadata,by="variable")
df3$Samples <- factor(df3$Samples, levels = c("PRE-CX", "POST-CX","CRPC", "ENZS","ENZR"))
ggplot(df3, aes(x=Samples, y=value,col=Samples))+ 
  geom_boxplot(lwd=0.4,fatten=2,alpha=0.2,outlier.shape=NA)+ scale_color_manual(values=c("PRE-CX"="#984EA3","POST-CX"="#FF7F00",CRPC="#E41A1C",ENZS="#4DAF4A",ENZR="#377EB8"))+theme_classic(base_size = 20)+theme(axis.text.x = element_text(angle = 45, hjust=1))+ylab("GSVA scores (Proliferation pathways)") 


##Wilcoxon test
PRECX  = df3[which(df3$Samples=="PRE-CX"),]
POSTCX  = df3[which(df3$Samples=="POST-CX"),]
CRPC  = df3[which(df3$Samples=="CRPC"),]
ENZS  = df3[which(df3$Samples=="ENZS"),]
ENZR  = df3[which(df3$Samples=="ENZR"),]

wilcox.test(PRECX$value,POSTCX$value)
wilcox.test(PRECX$value,CRPC$value)
wilcox.test(PRECX$value,ENZS$value)
wilcox.test(PRECX$value,ENZR$value)
wilcox.test(ENZS$value,ENZR$value)
