##loading libraries
library(data.table)
library(ranger)
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


hyper_grid <- expand.grid(
  mtry       = 1:10,
  num.trees = seq(100,1000,100),
  MSE   = 0
)


for (i in 1:length(Val)){
  
  pos = which(Train_set[,1] %in% Val[[i]])
  train = Train_set[-pos,c(3:ncol(Train_set))]
  Vals = Train_set[pos,c(3:ncol(Train_set))]
  
  for(j in 1:nrow(hyper_grid)) {
    
    
    # train model
    rf <- ranger(
      formula        = ln_ic50 ~ .,
      data           = train,
      num.trees      = hyper_grid$num.trees[j],
      mtry           = hyper_grid$mtry[j])
    # add MSE to grid
    hyper_grid$MSE[j] <- rf$prediction.error
    
  }
  inx = which.min(hyper_grid$MSE)
  model <- ranger(ln_ic50~ .,data = train, num.trees = hyper_grid$num.trees[inx], mtry = hyper_grid$mtry[inx])
  save(model, file = paste0("Gene_model_ranger_",i, ".RData"))
}


#################################Training on full data using tuned models####################################
#############################################################################################################
set.seed(123)
load("/home/smritic/NatComm/GeneBased/Ranger/data/Train_set.Rdata")
Train = Train_set[,3:ncol(Train_set)]
files = list.files(pattern = ".RData")

for (i in 1:length(files)){
  load(files[[i]])
  model <- rand_forest(mode = "regression") %>%
    set_engine("ranger") %>%
    fit(ln_ic50 ~ ., data = Train)
  save(model, file = paste0("/home/smritic/NatComm/GeneBased/Ranger/Complete_data/Gene_model_ranger_",i, ".RData"))
}





