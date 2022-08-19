##loading libraries
library(caret)
library(glmnet)

##loading models
x=load("Model_enet_1.RData")
model1= get(x)
x=load("Model_enet_2.RData")
model2= get(x)
x=load("Model_enet_3.RData")
model3= get(x)
x=load("Model_enet_4.RData")
model4= get(x)
x=load("Model_enet_5.RData")
model5= get(x)

##Loading test data
load("Test_set.Rdata")
drugs = unique(Test_set$drug_name)

##Finding correlation
correlation = list()
for (i in unique(drugs)){
  pos = which(Test_set$drug_name==i)
  test1 = Test_set[pos,]
  xtest = as.matrix(test1[,3:602])
  IC50 = test1[,603]

##Predictions
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

