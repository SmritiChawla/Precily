##loading libraries
library(survival)
library(survminer)

##loading predictions
predictions = read.csv("Predictions_on_TCGA_test_dataset.csv",sep=",",header=T,stringsAsFactors = F)
colnames(predictions)[1] = "submitter_id"


##loading TCGA clinical data file
clin = read.csv("TCGA_clinical_metadata.csv",sep=",",header=T,stringsAsFactors = F,row.names = 1)


##Data preparation
df = merge(predictions,clin,by="submitter_id")

##Stratifying patients based on median value of probability of response
med = median(df$p1)
pos1 = which(df$p1> med)
pos2 = which(df$p1 < med)

Group1 = df[pos1,]
Group2 = df[pos2,]

group = c(rep("Group 1",nrow(Group1)),rep("Group 2",nrow(Group2)))
surv = cbind.data.frame(rbind.data.frame(Group1,Group2),group)

##Computing Survival
fit <- survfit(Surv(OS, vital_status) ~ group, data = surv)
summary(fit, times=seq(0,365*5,365))

ggsurvplot(fit, pval = TRUE, 
           break.time.by = 500,
           risk.table = TRUE,xlim=c(0,3000),
           risk.table.height = 0.3,palette=c("red","blue"),tables.theme = theme_cleantable(),risk.table.col="black",surv.median.line="hv",
)

