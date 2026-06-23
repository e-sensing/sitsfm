# retrive the samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
labels <- sits_labels(samples_v13)
names(labels) <- c(1:length(labels))
# retrieve the classified data cube
cerrado_class_v13a <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "~/sitsfm/inst/extdata/cerrado_class_30m/",
    bands = "class",
    labels = labels,
    version = "v13a"
)
samples_per_class <- c(
    "Annual_Crop" = 20000,
    "Cerradao" = 20000,
    "Cerrado" = 20000,
    "Mangrove" = 5000,
    "Nat_NonVeg" = 2000,
    "Open_Cerrado" = 20000,
    "Pasture" = 20000,
    "Perennial_Crop" = 15000,
    "Silviculture" = 15000,
    "Sugarcane" = 15000,
    "Water" = 5000
)

samples_ssl <- sits_stratified_sampling(
    cube = cerrado_class_v13a,
    samples_per_class = samples_per_class,
    overhead = 1.0,
    multicores = 8,
    memsize = 32
)

bdc_cerrado_2017_2018 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg/"
)

samples_ssl_ts_v2 <- sits_get_data(
    cube = bdc_cerrado_2017_2018,
    samples = samples_ssl,
    multicores = 8
)
saveRDS(samples_ssl_ts_v2, "~/sitsfm/inst/extdata/cerrado_samples/samples_ssl_ts_64dim_v2.rds")

mae_model_ltae_64_v2 <- sits_pre_train(
    samples = samples_ssl_ts_v2,
    encoder_method = sits_mae(
        embedding_dim = 64,
        encoder_model = sits_lighttae(),
        mask_ratio = 0.5,
        batch_size = 128
    )
)
saveRDS(mae_model_ltae_64_v2, "~/sitsfm/inst/extdata/cerrado_models/mae_model_ltae_64_v2.rds")


# encode samples v13
cerrado_samples_emb_64 <- sits_encode(
    data = samples_v13,
    encoder = mae_model_ltae_64_v2,
    multicores = 8,
    gpu_memory = 16,
    batch_size = 1024
)

mlp_model_emb64 <- sits_train(
    samples = cerrado_samples_emb_64,
    ml_method = sits_mlp(
        batch_size = 128
    )
)

cerrado_014012 <- dplyr::filter(
    bdc_cerrado_2017_2018,
    .data[["tile"]] == "014012"
)

cerrado_014012_emb <- sits_encode(
    data = cerrado_014012,
    encoder = mae_model_ltae_64_v2,
    multicores = 8,
    gpu_memory = 16,
    batch_size = 1024,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_014012/"
)

cerrado_014012_emb <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_014012/"
)


cerrado_014012_emb_probs <- sits_classify(
    data = cerrado_014012_emb,
    ml_model = mlp_model_emb64,
    memsize = 32,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 2048,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_mlp_64/",
    version = "mlp"
)
cerrado_014012_emb_smooth <- sits_smooth(
    cube = cerrado_014012_emb_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_mlp_64/",
    version = "mlp"
)
cerrado_014012_emb_class <- sits_label_classification(
    cerrado_014012_emb_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_mlp_64/",
    version = "mlp"
)
