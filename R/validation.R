cerrado_samples_v13a <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
cerrado_samples_emb <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a-emb.rds")


valid_orig <- sits_kfold_validate(
    samples = cerrado_samples_v13a,
    ml_method = sits_tempcnn(),
    folds = 5,
    multicores = 5,
    gpu_memory = 20,
    batch_size = 256
)

valid_emb <- sits_kfold_validate(
    samples = cerrado_samples_v13a,
    ml_method = sits_mlp(),
    folds = 5,
    multicores = 5,
    gpu_memory = 20,
    batch_size = 256
)
saveRDS(valid_orig, "~/sitsfm/inst/extdata/cerrado_models/validation_v13_tcnn.rds")
saveRDS(valid_emb, "~/sitsfm/inst/extdata/cerrado_models/validation_emb_mlp.rds")
