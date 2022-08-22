#######loading data for group1
g1 = read.csv("File_for_Group1.csv",row.names = 1)
g1 = g1[,c(2,3)]
colnames(g1) = c("Prediction", "Actual")
table_g1 <- table(g1)


#######loading data for group2
g2 = read.csv("File_for_Group2.csv",row.names = 1)
g2 = g2[,c(2,3)]
colnames(g2) = c("Prediction", "Actual")
table_g2 <- table(g2)
