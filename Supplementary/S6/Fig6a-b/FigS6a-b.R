##loading libraries
library(pheatmap)

##Group 1
group1 = read.csv("Group1.csv",sep=",",header=T,stringsAsFactors = F)
group1 = na.omit(group1)

g1=xtabs(Freq ~ Stage + Cancer, group1)
cols = colorRampPalette(c("white", "grey","red"))(100)
pheatmap(g1, display_numbers = T,cluster_rows = F,cluster_cols = F,color = cols,number_format= "%1.0f",border_color = "black")


##Group 2
group2 = read.csv("Group2.csv",sep=",",header=T,stringsAsFactors = F)
group2 = na.omit(group2)

g2=xtabs(Freq ~ Stage + Cancer, group2)
pheatmap(g2, display_numbers = T,cluster_rows = F,cluster_cols = F,color = cols,number_format= "%1.0f",border_color = "black")



