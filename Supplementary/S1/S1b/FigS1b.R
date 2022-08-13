##Loading libraries
library(ggplot2)

##Loading file consisting IC50 values from CTRPv2 and GDSC datasets
df = read.csv("File_for_FigS1b.csv",row.names = 1)


##plotting densities
ggplot(df,aes(x=LNIC50, col=group)) +
  geom_density(size=1) +theme_classic(base_size = 20) +scale_color_manual(values=c("blue","red"))
