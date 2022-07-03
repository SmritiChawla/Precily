###loading predictied and actual data
Test = read.csv("Test_predictions.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1,check.names = F)
ob = read.csv("Cellline_Drugs_IC50_test.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1,check.names = F)

###Computing correlation
corr =list()
for (i in 1:ncol(Test)){
  
  df = cbind(Test[,i],ob[,i])
  df = na.omit(df)
  corr[[i]] = cor(df[,1],df[,2])

}

correlation = do.call(rbind,corr)
