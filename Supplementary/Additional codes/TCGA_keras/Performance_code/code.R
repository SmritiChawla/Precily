##Loading libraries
library(keras)
library(caret)
library(ggpubr)
library(PRROC)


##Loading DNN bootstrapped models
model1 = load_model_hdf5("Model1.hdf5")
model2 = load_model_hdf5("Model2.hdf5")
model3 = load_model_hdf5("Model3.hdf5")
model4 = load_model_hdf5("Model4.hdf5")
model5 = load_model_hdf5("Model5.hdf5")



##Loading test dataset
test= read.csv("Test_data.csv",sep=",",header=T,stringsAsFactors = F)
xtest = test[,3:1429]
labels = test[,1430]
xtest = as.matrix(xtest)



##Making predictions
prediction1=model1 %>% predict(xtest)
prediction2=model2 %>% predict(xtest)
prediction3=model3 %>% predict(xtest)
prediction4=model4 %>% predict(xtest)
prediction5=model5 %>% predict(xtest)


##############################AUCPR calculation

fg <- prediction1[labels == 1]
bg <- prediction1[labels == 0]
pr1 <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)$auc.integral


fg <- prediction2[labels == 1]
bg <- prediction2[labels == 0]
pr2 <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)$auc.integral

fg <- prediction3[labels == 1]
bg <- prediction3[labels == 0]
pr3 <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)$auc.integral


fg <- prediction4[labels == 1]
bg <- prediction4[labels == 0]
pr4 <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)$auc.integral

fg <- prediction5[labels == 1]
bg <- prediction5[labels == 0]
pr5 <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = F)$auc.integral


AUCPR_mean = mean(c(pr1,pr2,pr3,pr4,pr5))
