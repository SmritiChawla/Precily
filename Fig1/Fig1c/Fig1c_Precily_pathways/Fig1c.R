##Loading libraries
library(keras)

##Unzip Test_set.zip and load Test dataset
test = read.csv("Test_Set.csv",sep= ",")
drugs = unique(test$X1)


correlation = list()
for (i in unique(drugs)){
  pos = which(test$X1==i)
  test1 = test[pos,]
  testd = as.matrix(test1[,3:1431])
  IC50 = test1[,1432]
  
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

##Correlation
cor = do.call(rbind,correlation)
