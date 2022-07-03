drugPred = function(enrichment.scores,metadata,CancerType){
drugsl =list()
for (i in 1:ncol(enrichment.scores)){
  expAve = as.matrix(enrichment.scores[,i])
  features = read.table("Features.csv",sep=",")[,1]
  common_features = intersect(c(rownames(expAve),colnames(metadata)),(features))
  Final_Index= which(metadata$TCGA_DESC %in% "PRAD")
  metainfo = metadata[Final_Index, ]  
  col=dim(metainfo)[1]
  output=sapply(features, function(x){
    if(x %in% common_features)
    {
      if(x %in% colnames(metainfo))
      {temp=metainfo[,x]}
      else if(x %in% rownames(expAve))
      {temp=rep(expAve[x,],col)}
    }else
    {
      temp=rep(NA,col)
      
    }
    return(temp)
    
  })
  
  impdata = impute.knn(t(output[,1:1329]))
  xtest = cbind(t(impdata$data),output[,1330:ncol(output)])
  colnames(drugs) = colnames(xtest)[1330:1429]
  pathfeatures = as.matrix(xtest[1,1:1329])
  
  unseen = list()
  for ( j in 1:nrow(drugs)){
    unseen[[j]] = cbind(t(pathfeatures),drugs[j,])
    
  }
  xtest = rbind(xtest,do.call(rbind,unseen))
  xtest = as.matrix(xtest)
  
  model1 = load_model_hdf5("Model1.hdf5")
  model2 = load_model_hdf5("Model2.hdf5")
  model3 = load_model_hdf5("Model3.hdf5")
  model4 = load_model_hdf5("Model4.hdf5")
  model5 = load_model_hdf5("Model5.hdf5")
  
  
  prediction1=model1 %>% predict(xtest)
  prediction2=model2 %>% predict(xtest)
  prediction3=model3 %>% predict(xtest)
  prediction4=model4 %>% predict(xtest)
  prediction5=model5 %>% predict(xtest)
  
  predictions = apply(cbind.data.frame(prediction1,prediction2,prediction3,prediction4,prediction5),1,mean)
  predictions=round(predictions,4)
  
  drugsl[[k]] = predictions[(nrow(metainfo)+1):length(prediction1)]
  
}
return(drugsl)
}