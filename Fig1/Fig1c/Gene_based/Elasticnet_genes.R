##loading libraries
library(data.table)
library(caret)
library(glmnet)
set.seed(123)

data = fread("Training_data.csv")
data = as.data.frame(data)
data = janitor::clean_names(data)


###Test dataset creation
set.seed(0)
inx = sample(unique(data[,1]),0.10*length(unique(data[,1])))
pos = which(data[,1] %in% inx)

Train_set <- data[-pos,]
Test_set  <- data[pos,]
save(Train_set,file="Train_set.Rdata")
save(Test_set,file="Test_set.Rdata")

## Split data cell line wise
CL_x = unique(Train_set[,1])


Val = list()
for(i in seq(1:5))
{
  if (i == 1)
  {
    Val[[i]] = CL_x[i:(length(CL_x) %/% 5)]
    Train = CL_x[((length(CL_x) %/% 5) + 1) : length(CL_x)]
  }
  else
  {
    Val[[i]] = CL_x[((i - 1) * (length(CL_x) %/% 5) + 1) : (i * (length(CL_x) %/% 5))]
    A = CL_x[1 : ((i - 1) * (length(CL_x) %/% 5))]
    B = CL_x[((i * (length(CL_x) %/% 5)) + 1) : length(CL_x)]
    Train = c(A, B)
  }
}

pos = which(Train_set[,1] %in% Val[[1]])

for (i in 1:length(Val)){
  pos = which(Train_set[,1] %in% Val[[i]])
  train = Train_set[-pos,c(3:ncol(Train_set))]
  Vals = Train_set[pos,c(3:ncol(Train_set))]
  model = train(ln_ic50~., data = train, method = "glmnet")
  model = model$finalModel
  save(model, file = paste0("Model_ELasticNet_",i, ".RData"))
} 


################################Training on complete data using tuned models##################################
##############################################################################################################
set.seed(123)
load("Train_set.Rdata")
Train = Train_set[,3:ncol(Train_set)]

files = list.files(pattern = ".RData")

for (i in 1:length(files)){
  load(files[[i]])
  glm_model = train(ln_ic50~., data = Train, method = "glmnet",trControl = trainControl(method = 'none'), tuneGrid = expand.grid(
    lambda = model$tuneValue$lambda, alpha = model$tuneValue$alpha))
  save(glm_model, file = paste0("/home/smritic/NatComm/GeneBased/ELasticNet/Complete_data/Model_enet_",i, ".RData"))
  
}

