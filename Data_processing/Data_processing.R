##loading libraries
library(data.table)

##loading GSVA scores data
##Loading metadata 
load("CCLE_GSVA_SCORES.RData")
load("GDSC2_metadata.RData")

df = t(data)
df1 = cbind.data.frame(rownames(df),df)
colnames(df1)[1] = "CELL_LINE_NAME"


data_table_1 = data.table(df1, key="CELL_LINE_NAME")
data_table_2 = data.table(metadata, key="CELL_LINE_NAME")

dt.merged <- merge(data_table_1, data_table_2)

mat = dt.merged[,c(2:1330,1332:1431,1433)]
final = cbind.data.frame(dt.merged$CELL_LINE_NAME,dt.merged$DRUG_NAME,mat)
final = data.table(final)
fwrite(final,file="Complete_Training_data_for_DNN.csv")
