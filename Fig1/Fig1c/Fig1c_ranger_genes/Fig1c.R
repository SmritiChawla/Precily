##loading libraries
library(ranger)
library(caret)
library(parsnip)

##load models
##Models can be downloaded from [https://drive.google.com/drive/folders/1BbSNS_DXSaLgXt8MVeoySdr0uB-81xKJ?usp=sharing]

x=load("Gene_model_ranger_1.RData")
model1= get(x)

x=load("Gene_model_ranger_2.RData")
model2= get(x)

x=load("Gene_model_ranger_3.RData")
model3= get(x)

x=load("Gene_model_ranger_4.RData")
model4= get(x)

x=load("Gene_model_ranger_5.RData")
model5= get(x)

##Load test dataset
load("Test_set.Rdata")
drugs = unique(Test_set$drug_name)

##Compute correlation
correlation = list()
for (i in unique(drugs)){
  pos = which(Test_set$drug_name==i)
  test1 = Test_set[pos,]
  testData = test1[,3:602]
  IC50 = test1[,603]
  ##Predictions
  prediction1 = predict(model1, testData)
  prediction2 = predict(model2,testData)
  prediction3 = predict(model3, testData)
  prediction4 = predict(model4, testData)
  prediction5 = predict(model5, testData)
  predictions = apply(cbind.data.frame(prediction1,prediction2,prediction3,prediction4,prediction5),1,mean)
  correlation[[i]] = cor(predictions, IC50)
}

cor = do.call(rbind,correlation)
