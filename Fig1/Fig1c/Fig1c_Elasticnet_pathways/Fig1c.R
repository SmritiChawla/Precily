##loading libraries
library(caret)
library(glmnet)

##loading models
x=load("Pathways_model_ElasticNet_1.RData")
model1= get(x)
x=load("Pathways_model_ElasticNet_2.RData")
model2= get(x)
x=load("Pathways_model_ElasticNet_3.RData")
model3= get(x)
x=load("Pathways_model_ElasticNet_4.RData")
model4= get(x)
x=load("Pathways_model_ElasticNet_5.RData")
model5= get(x)

##Unzip test data file and load test dataset
test= read.csv("Test_Set.csv",sep=",",header=T,stringsAsFactors = F)
drugs = unique(test$X1)

correlation = list()
for (i in unique(drugs)){
  pos = which(test$X1==i)
  test1 = test[pos,]
  xtest = as.matrix(test1[,3:1431])
  IC50 = test1[,1432]

  ##predictions
  prediction1 = predict(model1, xtest)
  prediction2 = predict(model2, xtest)
  prediction3 = predict(model3, xtest)
  prediction4 = predict(model4, xtest)
  prediction5 = predict(model5, xtest)
  predictions = apply(cbind.data.frame(prediction1,prediction2,prediction3,prediction4,prediction5),1,mean)
  correlation[[i]] = cor(predictions, IC50)
}

##Correlation
cor = do.call(rbind,correlation)
