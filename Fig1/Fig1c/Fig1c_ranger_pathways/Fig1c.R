##loading libraries
library(caret)
library(ranger)
library(parsnip)


##Models can be downloaded from [https://drive.google.com/drive/folders/1BbSNS_DXSaLgXt8MVeoySdr0uB-81xKJ?usp=sharing]
x=load("Pathways_model_ranger_1.RData")
model1= get(x)

x=load("Pathways_model_ranger_2.RData")
model2= get(x)

x=load("Pathways_model_ranger_3.RData")
model3= get(x)

x=load("Pathways_model_ranger_4.RData")
model4= get(x)

x=load("Pathways_model_ranger_5.RData")
model5= get(x)

##Unzip and load Test dataset
test= read.csv("Test_Set.csv",sep=",",header=T,stringsAsFactors = F)
drugs = unique(test$X1)

##Compute correlation
correlation = list()
for (i in unique(drugs)){
  pos = which(test$X1==i)
  test1 = test[pos,]
  testData = test1[,3:1431]
  IC50 = test1[,1432]
  ##Predictions
  prediction1 = predict(model1, testData)
  prediction2 = predict(model2, testData)
  prediction3 = predict(model3, testData)
  prediction4 = predict(model4, testData)
  prediction5 = predict(model5, testData)
  predictions = apply(cbind.data.frame(prediction1,prediction2,prediction3,prediction4,prediction5),1,mean)
  correlation[[i]] = cor(predictions, IC50)
}

cor = do.call(rbind,correlation)
