cerrado_embeddings_2017_2018 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_2017_2018/"
)
plot(cerrado_embeddings_2017_2018, tile = "017004", red = "E2", green = "E1", blue = "E3")

cerrado_samples_emb <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a-emb.rds")

svm_model <- sits_train(
    samples = cerrado_samples_emb,
    ml_method = sits_svm()
)
saveRDS(svm_model, "~/sitsfm/inst/extdata/cerrado_models/svm_model")

cube_emb_017004 <- dplyr::filter(
    cerrado_embeddings_2017_2018,
    .data[["tile"]] == "017004"
)
cube_emb_017004_probs <- sits_classify(
    data = cube_emb_017004,
    ml_model = svm_model,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_svm/",
    version = "svm"
)

cube_emb_017004_smooth <- sits_smooth(
    cube = cube_emb_017004_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_svm/",
    version = "svm"
)
cube_emb_017004_class <- sits_label_classification(
    cube = cube_emb_017004_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_svm/",
    version = "svm"
)
