#!/usr/bin/env Rscript
# inputs    -------------------------------------------------------------------
library(argparser)

p = arg_parser("Run training pipeline")
p = add_argument(p, "drug", help = "Drug to learn")
p = add_argument(p, "matrix", help = "Matrix to train on (RDS file)")
p = add_argument(p, "hyperparams", help = "json file with hyper parameters")
p = add_argument(p, "prefix", help = "prefix to write files")
p = add_argument(p, "--max_models", default = 15L,
                 help = "Max number of models to compute")
p = add_argument(p, "--varcut", default = 100,
                 help = "Percent of genes to keep based on variance.")
p = add_argument(p, "--learner", default = "DL",
                 help = "Algorithm to use for learning (DL, RF, GLM)")
p = add_argument(p, "--test", help = "Path to clinical data")
p = add_argument(p, "--kfold", default = 5L, help = "Number of CV-splits")
p = add_argument(p, "--max_mem", default = "64G", help = "H2O parameter")
p = add_argument(p, "--cores", default = "Slurm",
                 help = "Method to determine cores with future::availableCores")

argv = parse_args(p)
# argv = parse_args(p, c("Bortezomib", "bortezomib_train.rds", "hyperparam_grid_dl.json",
#                        "debug", "--max_models", "2", "--varcut", "50"))

message("Running with the following arguments")
# str(argv)

drug = argv$drug
mat_file = argv$matrix
lift_null_file = argv$lift
hyperparam_file = argv$hyperparams
prefix = argv$prefix
Nmodels = argv$max_models
varcut = argv$varcut
learner = argv$learner
kfold = argv$kfold
max_mem = argv$max_mem
test_file = argv$test
cores_method = argv$cores

stopifnot(learner %in% c("DL", "RF", "GLM"))

Ncores = future::availableCores(method = cores_method)
options(mc.cores = Ncores)


# Library    -------------------------------------------------------------------

suppressPackageStartupMessages({
    library(tidyverse)
    library(parallel)
    library(glmnet)
    library(glmnetUtils)
    library(h2o)
})

all_equal = function(x, y) {
    if (length(y) == 1)
        y = rep(y, length(x))
    !is.character(all.equal(x, y, check.attributes = FALSE))
}

is_scaled = function(mat) {
    # result of `stat::scale`
    if (!is.null(attr(mat, "scaled:center")) )
        return(TRUE)
    # zero-mean
    cmeans = colMeans(mat, na.rm = TRUE)
    if (!all_equal(cmeans, 0))
        return(FALSE)
    # unit variance
    csd = apply(mat, 2, sd)
    if (!all_equal(csd, 1))
        return(FALSE)

    return(TRUE)
}

rbind_data_frame = function(...)
    # simple wrapper
    rbind.data.frame(..., make.row.names = FALSE, stringsAsFactors = FALSE)

delist_col = function(x, collapse = '|') {
    if (!is.list(x))
        return(x)
    vapply(x, paste, '', sep = '', collapse = collapse)
}

delist_df = function(x, collapse = '|')
    as.data.frame(lapply(x, delist_col, collapse = collapse))

FS_top = function(mat, top) {
    ix = apply(mat[, genes], 2, mad, na.rm = TRUE)
    ix = order(ix, decreasing = TRUE)[1:top]
    genes = genes[ix]
    c(genes, tissues)
}

expand_hyperparams_h2o = function(hyper_params) {
    hyper_params = split(hyper_params, seq(nrow(hyper_params)))
    hyper_params = lapply(hyper_params, as.list)
    names(hyper_params) = NULL
    for (i in seq(length(hyper_params))) {
        for (j in seq(length(hyper_params[[i]]))) {
            if (is.list(hyper_params[[i]][[j]]))
                hyper_params[[i]][[j]] = unlist(hyper_params[[i]][[j]],
                                                recursive = FALSE,
                                                use.names = FALSE)
        }
    }
    hyper_params
}

validate_h2o = function(model, newdata) {
    y_hat = h2o.performance(model, newdata)
    data.frame(MSE = h2o.mse(y_hat), MAE = h2o.mae(y_hat))
}

validate_glmnet = function(model, newdata, s = 'lambda.min') {
    idrug = which(colnames(newdata) == drug)
    y_hat = predict(model, newdata[, -idrug], s = s)
    dy = y_hat - newdata[, idrug]
    data.frame(lambda = model[[s]],  # hacky
               MSE = mean(dy * dy), MAE = mean(abs(dy)))
}


# Preprocessing -----------------------------------------------------------------

message(paste0('Sourcing ', hyperparam_file, "..."))
hyper_params <- jsonlite::fromJSON(hyperparam_file,
                                   simplifyVector = TRUE,
                                   simplifyDataFrame = FALSE,
                                   simplifyMatrix = FALSE)

message(paste0('Reading ', mat_file, '...'))
mat = as.matrix(readRDS(mat_file))
tissues = grep("^Tissue_", colnames(mat), value = TRUE)
if (any(grepl("_GE", colnames(mat)))) {
    genes = grep("_GE$", colnames(mat), value = TRUE)
} else {
    genes = setdiff(colnames(mat), c(drug, tissues))
}

message('Subseting matrix...')
mat = mat[!is.na(mat[, drug]), c(drug, genes), drop = FALSE]

# k-fold cross-validation
fold_id = cut(1:nrow(mat), breaks = kfold, labels = FALSE)
fold_size = sum(fold_id != 1L)
mat = mat[sample(nrow(mat)), ]

message(sprintf('Selecting genes based on top %.1f%% variance cutoff', varcut))
top = floor(varcut * length(genes) / 100)
features = mclapply(1:kfold, function(i) FS_top(mat[fold_id != i, ], top))
features[[kfold + 1L]] = FS_top(mat, top)

message('Setting up learning algorithm...')
if (learner == "DL") {
    h2o.init(nthreads = Ncores, max_mem_size = max_mem)
    convert = as.h2o
    learn = h2o.deeplearning
    validate = validate_h2o
    predict = h2o.predict
    hyper_params_df = lapply(hyper_params, expand.grid,
                             KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
    hyper_params_df = Reduce(rbind_data_frame, hyper_params_df)
    Nmodels = min(Nmodels, nrow(hyper_params_df))
    hyper_params_df = hyper_params_df[sample(nrow(hyper_params_df), Nmodels), ]
    hyper_params = expand_hyperparams_h2o(hyper_params_df)
    hyper_params_df = cbind(data.frame(model_id = 1:Nmodels), hyper_params_df)
    saveModel = function(x, nam) h2o.saveModel(x, paste0(nam, ".h2o"))
} else if (learner == "RF") {
    h2o.init(nthreads = Ncores, max_mem_size = max_mem)
    convert = as.h2o
    learn = h2o.randomForest
    validate = validate_h2o
    predict = h2o.predict
    hyper_params_df = lapply(hyper_params, expand.grid,
                             KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
    hyper_params_df = Reduce(rbind_data_frame, hyper_params_df)
    Nmodels = min(Nmodels, nrow(hyper_params_df))
    hyper_params_df = hyper_params_df[sample(nrow(hyper_params_df), Nmodels), ]
    hyper_params = expand_hyperparams_h2o(hyper_params_df)
    hyper_params_df = cbind(data.frame(model_id = 1:Nmodels), hyper_params_df)
    saveModel = function(x, nam) h2o.saveModel(x, paste0(nam, ".h2o"))
} else {
    # GLM
    convert = function(x, ...) as.matrix(x)
    learn = function(training_frame, y, x, alpha) {
        cv.glmnet(training_frame[, x], training_frame[, y],
                  parallel = TRUE, alpha = alpha, family = "gaussian")
    }
    validate = validate_glmnet
    hyper_params = hyper_params
    hyper_params_df = data.frame(model_id = 1:length(hyper_params),
                                 alpha = hyper_params)
    saveModel = function(x, nam) saveRDS(x, paste0(nam, ".rds"))
    Nmodels = length(hyper_params)
}

message('Running cross-validation')
cvSummary = vector("list", kfold)
for (i in seq_len(kfold)) {
    kmat = mat[, c(drug, features[[i]]), drop = FALSE]
    ix = which(fold_id == i)
    train_hex = convert(kmat[-ix, , drop = FALSE])
    valid_hex = convert(kmat[ix, , drop = FALSE])
    kmodel = lapply(hyper_params, function(params) {
                    x = features[[i]]
                    if ('mtries' %in% names(params)) {# special case
                        params[['mtries']] = round(params[['mtries']] * length(x))
                    }
                    do.call(learn, c(list(y = drug, x = x,
                                          training_frame = train_hex),
                                     params))
                  })
    kvalid = lapply(kmodel, validate, newdata = valid_hex)
    kvalid = do.call(rbind, kvalid)
    tmp_df = cbind(data.frame(fold_id = rep(i, Nmodels)),
                   hyper_params_df,
                   kvalid)
    rownames(tmp_df) = NULL
    cvSummary[[i]] = tmp_df
}


# Write results -----------------------------------------------------------

cvSummary = do.call(rbind, cvSummary)
cvSummary = delist_df(cvSummary)
cvSummary = cvSummary[order(cvSummary[["MSE"]]), ]
write_csv(cvSummary, paste0(prefix, "_cv.csv"))

cvSummary = cvSummary %>%
    group_by_at(vars(-fold_id, -MSE, -MAE)) %>%
    summarize(MSE_sd = sd(MSE, na.rm = TRUE),
              MSE = mean(MSE, na.rm = TRUE),
              MAE_sd = sd(MAE, na.rm = TRUE),
              MAE = mean(MAE, na.rm = TRUE)) %>%
    ungroup() %>%
    arrange(MSE)
write_csv(cvSummary, paste0(prefix, "_cvSummary.csv"))

# Train best model on all of the data
best_model = cvSummary$model_id[1L]
train_hex = convert(mat)
params = hyper_params[[best_model]]
x = features[[kfold + 1L]]
if ('mtries' %in% names(params))
    params[['mtries']] = floor(params[['mtries']] * length(x))
model = do.call(learn, c(list(y = drug, x = x, training_frame = train_hex), params))
saveModel(model, prefix)

if (!is.na(test_file)) {
    test = readRDS(test_file)
    patient_id = rownames(test)
    test = convert(test[, x, drop = FALSE])
    y = as.vector(predict(model, test))
    df = tibble(patient_id = patient_id, ic50 = y)
    write_csv(df, paste0(prefix, "_clinicalPrediction.csv"))
}

if (learner %in% c("DL", "RF"))
    h2o.shutdown(FALSE)
