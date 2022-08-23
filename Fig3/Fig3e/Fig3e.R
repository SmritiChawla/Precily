##Loading libraries
library(reshape2)
library(ggplot2)

##loading data
load("enrichment.scores.Rdata")

##averaging GSVA scores of biological replicates of samples
enrichment.scores =t(apply(enrichment.scores, 1, function(x) tapply(x, colnames(enrichment.scores), mean)))

##Subsetting proliferation realted pathways
pathways = c("KEGG_RIBOSOME","KEGG_DNA_REPLICATION","REACTOME_TRANSLATION","REACTOME_PEPTIDE_CHAIN_ELONGATION","REACTOME_CYCLIN_E_ASSOCIATED_EVENTS_DURING_G1_S_TRANSITION_","REACTOME_M_G1_TRANSITION","REACTOME_G1_S_TRANSITION","REACTOME_CYCLIN_A_B1_ASSOCIATED_EVENTS_DURING_G2_M_TRANSITION","REACTOME_CDT1_ASSOCIATION_WITH_THE_CDC6_ORC_ORIGIN_COMPLEX","REACTOME_SYNTHESIS_OF_DNA","REACTOME_ASSEMBLY_OF_THE_PRE_REPLICATIVE_COMPLEX","REACTOME_S_PHASE")
pos = which(rownames(enrichment.scores) %in% pathways)
df = enrichment.scores[pos,]
df1 = cbind.data.frame(rownames(df),df)
rownames(df1) = NULL
colnames(df1)[1] = "Pathways" 
final = melt(df1)
final$variable<-sub(".*\\.", "", final$variable)

##Plotting distribution of GSVA scores of proliferation related pathways for DHT vs ETOH
ggplot(final, aes(x=variable, y=value,col=variable))+ 
    geom_boxplot(lwd=0.4,fatten=2,alpha=0.2,outlier.shape=NA)+ 
    geom_point(position=position_jitter(width=0.15, height=0.0,seed=1),size=2,alpha=1)+
    scale_colour_manual(values=c(DHT="#E41A1C",VEH="#66628D"))+  
    theme_classic(base_size = 25)+ 
    guides(color = guide_legend(ncol=1)) + theme(axis.text.x = element_text(angle = 45, hjust=1,size=15),axis.text.y = element_text(size=15)) +  xlab("") + ylab("GSVA scores
    (Proliferation pathways)")+theme(legend.position="none")

  
