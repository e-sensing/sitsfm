cerrado_cube_017004 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    tiles = "017004",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg/"
)
samples_ssl_ts_v2 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples_ssl_ts_64dim_v2.rds")

mae_model <- sits_pre_train(
    samples = samples_ssl_ts_v2,
    encoder_method = sits_mae(
        embedding_dim = 64,
        encoder_model = sits_lighttae(),
        masking_method = "random",
        mask_ratio = 0.5,
        batch_size = 128
    )
)
saveRDS(mae_model, "~/sitsfm/inst/extdata/cerrado_models/mae_model.rds")

cerrado_cube_017004 <- dplyr::filter(
    cerrado_cube_reg, tile == "017004"
)
# retrive the MAE model
mae_model <- readRDS("~/sitsfm/inst/extdata/cerrado_models/mae_model.rds")
# encode the tile
cerrado_emb_mae_017004 <- sits_encode(
    data = cerrado_cube_017004,
    encoder = mae_model,
    memsize = 18,
    multicores = 8,
    gpu_memory = 16,
    batch_size = 4096,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_mae/"
)
# recover the embedded cube
#
cerrado_emb_mae <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_mae/"
)

# retrieve the samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")

# encode the samples
embed_samples <- sits_encode(
    data = samples_v13,
    encoder = mae_model,
    multicores = 8,
    gpu_memory = 18,
    batch_size = 4096
)
mlp_model_mae <- sits_train(
    samples = embed_samples,
    ml_method = sits_mlp(
        batch_size = 256,
        verbose = TRUE
    )
)
plot(mlp_model_mae)

cerrado_emb_probs <- sits_classify(
    data = cerrado_emb_mae,
    ml_model = mlp_model_mae,
    memsize = 16,
    multicores = 8,
    gpu_memory = 18,
    batch_size = 4096,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_mae64_class/",
    version = "mlp"
)
cerrado_emb_smooth <- sits_smooth(
    cube = cerrado_emb_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_mae64_class/",
    version = "mlp"
)
cerrado_emb_class <- sits_label_classification(
    cerrado_emb_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_mae64_class/",
    version = "mlp"
)
