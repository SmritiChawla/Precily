##loading libraries
library(caret)
library(ggpubr)

##loading predictions vs actual file
df = read.csv("Predictions_vs_Actual.csv")

##computing metrics
perf = data.frame(
  Rsquare = R2(df[,3],df[,4]),
  correlation = cor(df[,3], df[,4]))


##Plotting sensity scatter plot for actual vs predicted labels
df = cbind.data.frame(df[,4],df[,3])
colnames(df) = c("Actual","Predicted")

get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}
df$density <- get_density(df$Actual, df$Predicted,n=50)
g=ggscatter(df, x = "Actual", y = "Predicted", 
            add = "reg.line", conf.int = TRUE, 
            cor.coef = TRUE, cor.method = "pearson",color = "density",
            xlab = "GDSC Z-score", ylab = " Predicted Z-score",add.params = list(color="black"),cor.coef.size = 10)
g+  scale_colour_gradientn(colours = terrain.colors(10))+theme_classic() +theme(axis.text=element_text(size=25))






