##loading libraries
library(data.table)
library(h2o)
h2o.init()

##Loading data
df = fread("TCGA_training_data.csv")
df = df[,-c(3)]
data = as.data.frame(df)
data$label = as.factor(data$label)
data$Stage = as.factor(data$Stage)


###Test dataset creation
set.seed(10)
random = sample(unique(data$patient.arr),0.10*length(unique(data$patient.arr)))
pos = which(data$patient.arr %in% random)
Train_set <- data[-pos,]
Test_set  <- data[pos,]

## Split data patient wise
CL_x = unique(Train_set$patient.arr)
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

folds = list()
for (i in 1:length(Val)){
  folds[[i]] = cbind.data.frame(rep(i,length(Val[[i]])),Val[[i]])
  colnames(folds[[i]]) = c("Folds","patient.arr")
  
}

foldsc = do.call(rbind,folds)

train =merge(foldsc,Train_set,by="patient.arr")
train = train[,-c(1)]
train =  as.h2o(train)


# Response column
y <- "label"
x <- setdiff(setdiff(names(train), y), "Folds")


# Run AutoML 
aml <- h2o.automl(x = x, y = y,
                  training_frame = train,
                  max_models = 20,
                  seed = 14,max_runtime_secs=0,keep_cross_validation_predictions = T,keep_cross_validation_fold_assignment = T,keep_cross_validation_models = T,fold_column = "Folds",balance_classes = F)

###Compute performance on Test dataset using best model
test = as.h2o(Test_set[,-c(1)])
per=h2o.performance(aml@leader,test)

