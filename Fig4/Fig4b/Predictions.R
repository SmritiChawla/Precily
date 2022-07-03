##loading libraries
library(impute)
library(keras)
library(umap)


source("DrugsPred.R")


##loading GSVA scores
load("enrichment.scores.Rdata")


##loading metadata file
load("GDSC2_metadata.RData")

##Drug response prediction
df1 = drugPred(enrichment.scores,metadata,"PRAD")


##Reduce list to dataframe
Pred=df1 %>% purrr::reduce(left_join, by = "DRUGS")
Predictions = Pred[,2:ncol(Pred)]
rownames(Predictions) = Pred[,1]