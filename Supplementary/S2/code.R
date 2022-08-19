##Load libraries
library(ggpubr)

########LNCaP cell line correlation
load("CCLE_gene_expression.Rdata")
pos = which(colnames(mat2) == "LNCAPCLONEFGC_PROSTATE")
CCLE = as.matrix(mat2[,pos])
rownames(CCLE) = rownames(mat2)
load("APCRCQ_PCa_Cell_lines.RData")
LNCAP = as.matrix(mat[,c(3,4)])
final = merge(LNCAP,CCLE,by=0)
colnames(final)[4] = "CCLE"
ggscatter(final, x = "FBS.LNCAP.1", y = "CCLE",
          add = "reg.line", color = "navyblue",                        
          conf.int = TRUE,cor.coef.size = 5, add.params = list(color = "red"),                      
          )+stat_cor()  


ggscatter(final, x = "FBS.LNCAP.2", y = "CCLE",
          add = "reg.line", color = "navyblue",                        
          conf.int = TRUE,cor.coef.size = 5, add.params = list(color = "red"),                      
)+stat_cor()  



########DU145 cell line correlation
load("CCLE_gene_exp.Rdata")
pos = which(colnames(mat2) == "DU145_PROSTATE")
CCLE = as.matrix(mat2[,pos])
rownames(CCLE) = rownames(mat2)


load("APCRCQ_PCa_Cell_lines.RData")
DU145 = as.matrix(mat[,c(1,2)])
final = merge(DU145,CCLE,by=0)
colnames(final)[4] = "CCLE"
ggscatter(final, x = "FBS.DU145.1", y = "CCLE",
          add = "reg.line", color = "navyblue",                        
          conf.int = TRUE,cor.coef.size = 5, add.params = list(color = "red"),                      
)+stat_cor()  


ggscatter(final, x = "FBS.DU145.3", y = "CCLE",
          add = "reg.line", color = "navyblue",                        
          conf.int = TRUE,cor.coef.size = 5, add.params = list(color = "red"),                      
)+stat_cor()  


########PC3 cell line correlation
load("CCLE_gene_exp.Rdata")
pos = which(colnames(mat2) == "PC3_PROSTATE")
CCLE = as.matrix(mat2[,pos])
rownames(CCLE) = rownames(mat2)
load("APCRCQ_PCa_Cell_lines.RData")
PC3 = as.matrix(mat[,c(5,6)])
final = merge(PC3,CCLE,by=0)
colnames(final)[4] = "CCLE"
ggscatter(final, x = "FBS.PC3.2", y = "CCLE",
          add = "reg.line", color = "navyblue",                        
          conf.int = TRUE,cor.coef.size = 5, add.params = list(color = "red"),                      
)+stat_cor()  


ggscatter(final, x = "FBS.PC3.3", y = "CCLE",
          add = "reg.line", color = "navyblue",                        
          conf.int = TRUE,cor.coef.size = 5, add.params = list(color = "red"),                      
)+stat_cor()  


########VCAP cell line correlation
load("CCLE_gene_exp.Rdata")
pos = which(colnames(mat2) == "VCAP_PROSTATE")
CCLE = as.matrix(mat2[,pos])
rownames(CCLE) = rownames(mat2)
load("APCRCQ_PCa_Cell_lines.RData")
VCAP = as.matrix(mat[,c(9,10)])
final = merge(VCAP,CCLE,by=0)
colnames(final)[4] = "CCLE"
ggscatter(final, x = "FBS.VCAP.1", y = "CCLE",
          add = "reg.line", color = "navyblue",                        
          conf.int = TRUE,cor.coef.size = 5, add.params = list(color = "red"),                      
)+stat_cor()  


ggscatter(final, x = "FBS.VCAP.2", y = "CCLE",
          add = "reg.line", color = "navyblue",                        
          conf.int = TRUE,cor.coef.size = 5, add.params = list(color = "red"),                      
)+stat_cor()  
