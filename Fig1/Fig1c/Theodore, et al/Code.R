files = list.files(pattern=".rds")
for (i in 1:length(files)){
system(paste("Rscript", "tune_drug.R", strsplit(files[[i]], "\\.")[[1]][1], files[i], "grid_dl.json", files[i],"-v",10, "-t", "/home/smritic/NatComm/Cell_reports/Test/test.rds", "-c", 4))}