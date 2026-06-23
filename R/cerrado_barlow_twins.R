samples_ssl_ts_v2 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples_ssl_ts_64dim_v2.rds")

btwins_model <- sits_pre_train(
    samples = samples_ssl_ts_v2,
    encoder_method = sits_barlow_twins(
        embedding_dim = 64,
        proj_dim = 128,
        encoder_model = sits_lighttae(),
        batch_size = 256
    )
)
saveRDS(btwins_model, "~/sitsfm/inst/extdata/cerrado_models/btwins_model.rds")
# retrieve the samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
labels <- sits_labels(samples_v13)
names(labels) <- c(1:length(labels))

embed_samples <- sits_encode(
    data = samples_v13,
    encoder = btwins_model,
    multicores = 8,
    gpu_memory = 20
)
val_emb <- sits_kfold_validate(
    samples = embed_samples,
    ml_method = sits_mlp(),
    multicores = 5,
    gpu_memory = 20
)

mlp_model <- sits_train(
    samples = embed_samples,
    ml_method = sits_mlp()
)

bdc_cerrado_2017_2018 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg/"
)
cerrado_014012 <- dplyr::filter(
    bdc_cerrado_2017_2018,
    .data[["tile"]] == "014012"
)
cerrado_014012_emb <- sits_encode(
    data = cerrado_014012,
    encoder = btwins_model,
    multicores = 8,
    gpu_memory = 16,
    batch_size = 2048,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_014012_bt16/"
)

cerrado_emb_bt <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_bt/"
)


cerrado_014012_emb_probs <- sits_classify(
    data = cerrado_014012_emb,
    ml_model = mlp_model,
    memsize = 32,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 2048,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_bt_class/",
    version = "mlp"
)
cerrado_014012_emb_smooth <- sits_smooth(
    cube = cerrado_014012_emb_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_014012_bt16_class/",
    version = "mlp"
)
cerrado_014012_emb_class <- sits_label_classification(
    cerrado_014012_emb_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_014012_bt16_class/",
    version = "mlp"
)

cerrado_017004 <- dplyr::filter(
    bdc_cerrado_2017_2018,
    .data[["tile"]] == "017004"
)

cerrado_017004_emb <- sits_encode(
    data = cerrado_017004,
    encoder = btwins_model,
    multicores = 8,
    gpu_memory = 16,
    batch_size = 1024,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_bt/"
)

cerrado_017004_emb_probs <- sits_classify(
    data = cerrado_017004_emb,
    ml_model = mlp_model,
    memsize = 32,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 2048,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_bt_class/",
    version = "mlp"
)
cerrado_017004_emb_smooth <- sits_smooth(
    cube = cerrado_017004_emb_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_bt_class/",
    version = "mlp"
)
cerrado_017004_emb_class <- sits_label_classification(
    cerrado_017004_emb_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_bt_class/",
    version = "mlp"
)
