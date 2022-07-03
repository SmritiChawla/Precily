##loading libraries
library(keras)
library(ggpubr)
library(caret)


test = read.csv("Test_data.csv",sep= ",")
testd = as.matrix(test[,3:1431])
IC50 = test[,1432]


##loading models
model1 = load_model_hdf5("Model1.hdf5")
model2 = load_model_hdf5("Model2.hdf5")
model3 = load_model_hdf5("Model3.hdf5")
model4 = load_model_hdf5("Model4.hdf5")
model5 = load_model_hdf5("Model5.hdf5")



##Making predictions
prediction1=model1 %>% predict(testd)
prediction2=model2 %>% predict(testd)
prediction3=model3 %>% predict(testd)
prediction4=model4 %>% predict(testd)
prediction5=model5 %>% predict(testd)


##Averaging out predictions
predictions = apply(cbind.data.frame(prediction1,prediction2,prediction3,prediction4,prediction5),1,mean)


##computing metrics
perf = data.frame(
  Rsquare = R2(predictions,IC50),
  correlation = cor(predictions, IC50)
)


##Plotting sensity scatter plot for actual vs predicted labels
df = cbind.data.frame(IC50,predictions)
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
            xlab = "Real value", ylab = " Predicted value",add.params = list(color="black"),cor.coef.size = 6)
g+  scale_colour_gradientn(colours = terrain.colors(10))+theme_classic() +theme(axis.text=element_text(size=20))







