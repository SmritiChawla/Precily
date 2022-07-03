###loading data
metadata = read.csv("Groundtruth.csv",sep=",",header = T,stringsAsFactors = F,row.names = 1)
drugs = read.csv("drugs_list.csv",sep=",",header = F,stringsAsFactors = F)[,1]

##Computing correlation predictions vs actual
correlation = list()
files = list.files(pattern="_clinicalPrediction.csv")
for ( i in 1:length(files)){
  for (j in unique(drugs))

  f = read.csv(files[[i]],sep=",",stringsAsFactors = F)
  pos = which(metadata$DRUG_NAME==j)
  meta = metadata[pos,c(1,4)]
  
  colnames(f)[1] = colnames(meta)[1]
  df = merge(f,meta,by="CELL_LINE_NAME")
  correlation[[i]] = cor(df$ic50, df$LN_IC50)
}
names(correlation) = drugs
corr = do.call(rbind,correlation)

