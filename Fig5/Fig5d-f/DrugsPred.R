drugPred = function(enrichment.scores,metadata,CancerType){

pred = list()
for (i in 1:ncol(enrichment.scores)){
  expAve = as.matrix(enrichment.scores[,i])
  features = model1@parameters$x
  #features = features[-2]
  common_features = intersect(c(rownames(expAve),colnames(metadata)),(features))
  Final_Index= which(metadata$Cancer %in% CancerType)
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
  
  impdata = impute.knn(t(output[,1:1327]))
  xtest = cbind(t(impdata$data),output[,1328:ncol(output)])
  xtest = as.h2o(xtest)
  prediction <- predict(model1, xtest)
  prediction = as.data.frame(prediction)
  pred[[i]]= unique(cbind.data.frame(metainfo$drug.name,prediction$p1))
}
return(pred)
}