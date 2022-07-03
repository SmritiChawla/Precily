##Loading libraries
library(keras)
library(tidyverse)
library(pheatmap)
library(data.table)
library(caret)


test= read.csv("Test_data.csv",sep=",",header=T,stringsAsFactors = F)

drugs = unique(test$X1)

correlation = list()

for (i in unique(drugs)){
  
  
  pos = which(test$X1==i)
  test1 = test[pos,]
  
  testd = as.matrix(test1[,3:602])
  IC50 = test1[,603]
  
  
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
  correlation[[i]] = cor(predictions, IC50)

  
}

cor = do.call(rbind,correlation)
