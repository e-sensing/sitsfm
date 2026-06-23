samples_ssl_ts_v2 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples_ssl_ts_64dim_v2.rds")

ssl_bt_model <- sits_pre_train(
    samples = samples_ssl_ts_v2,
    encoder_method = sits_ssl_barlow_twins(
        embedding_dim = 64,
        proj_dim = 128,
        epochs = 250,
        batch_size = 256,
        patience = 30,
        min_delta = 0.5,
        encoder_model = sits_lighttae(),
        verbose = TRUE
    )
)
saveRDS(ssl_bt_model, "~/sitsfm/inst/extdata/cerrado_models/ssl_bt_model.rds")
# retrieve the samples
# retrieve the samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")

samples_emb_ssl_bt <- sits_encode(
    data = samples_v13,
    encoder = ssl_bt_model,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 1024
)
mlp_model <- sits_train(
    samples_emb_ssl_bt,
    ml_method = sits_mlp()
)
# samples_red_val <- sits_kfold_validate(
#     samples_red_emb,
#     ml_method = sits_mlp(),
#     multicores = 8,
#     gpu_memory = 20,
#     batch_size = 1024
# )
# create a cube for two tiles
cerrado_cube_tiles <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    tiles = c("014012", "017004", "009010", "013014", "015005", "015009"),
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg/"
)
cerrado_emb_2018_ssl_bt <- sits_encode(
        data = cerrado_cube_tiles,
        encoder = ssl_bt_model,
        memsize = 10,
        multicores = 8,
        gpu_memory = 20,
        batch_size = 4096,
        output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_ssl_bt/"
)
cerrado_emb_2018_ssl_bt_probs <- sits_classify(
    data = cerrado_emb_2018_ssl_bt,
    ml_model = mlp_model,
    memsize = 20,
    multicores = 10,
    gpu_memory = 20,
    batch_size = 4096,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_ssl_bt_class/",
    version = "mlp"
)
cerrado_emb_2018_ssl_bt_bayes <- sits_smooth(
    cube = cerrado_emb_2018_ssl_bt_probs,
    memsize = 36,
    multicores = 12,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_ssl_bt_class/",
    version = "mlp"
)

cerrado_emb_2018_ssl_bt_class <- sits_label_classification(
    cube = cerrado_emb_2018_ssl_bt_bayes,
    memsize = 36,
    multicores = 12,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_ssl_bt_class/",
    version = "mlp"
)

