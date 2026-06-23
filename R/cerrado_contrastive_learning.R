# read samples version 2
samples_ssl_ts_v2 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples_ssl_ts_64dim_v2.rds")

# semi-SSL using supervised contrastive learning
cl_model <- sits_pre_train(
    samples = samples_ssl_ts_v2,
    encoder_method = sits_contrastive_learning(
        embedding_dim = 64,
        proj_dim = 128L,
        temperature = 0.07,
        pair_smp_method = "label",
        num_pairs = 2*nrow(samples_red),
        encoder_model = sits_lighttae(),
        epochs = 250L,
        batch_size = 2048,
        patience = 50,
        verbose = TRUE
    )
)
cl_model <- readRDS("~/sitsfm/inst/extdata/cerrado_models/cl_model.rds")

# retrieve the samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")

# encode the samples using the CL model
encoded_samples_cl <- sits_encode(
    data = samples_v13,
    encoder = cl_model,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 4096
)
# perform k-fold validation
val_emb <- sits_kfold_validate(
    samples = encoded_samples_cl,
    ml_method = sits_mlp(),
    multicores = 5,
    gpu_memory = 20,
    batch_size = 4096
)
saveRDS(val_emb, "~/sitsfm/inst/extdata/cerrado_models/val_emb_cl_v2.rds")
#
#
# create a cube for two tiles
cerrado_cube_tiles <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    tiles = c("017004", "014012"),
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg/"
)

# create a cube for some tiles
cerrado_cube_tiles <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    tiles = c("009010", "013014", "015005", "015009"),
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg/"
)
# generate the embeddings for the cube
cerrado_emb_tiles <- sits_encode(
    data = cerrado_cube_tiles,
    encoder = cl_model,
    memsize = 12,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 4096,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_cl/"
)

mlp_model <- sits_train(
    samples = encoded_samples_cl,
    ml_method = sits_mlp()
)

cerrado_emb_cl_probs <- sits_classify(
    data = cerrado_emb_tiles,
    ml_model = mlp_model,
    memsize = 20,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 2048,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_cl_class/",
    version = "mlp"
)
cerrado_emb_cl_smooth <- sits_smooth(
    cube = cerrado_emb_cl_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_cl_class/",
    version = "mlp"
)
cerrado_emb_cl_class <- sits_label_classification(
    cerrado_emb_cl_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_cl_class/",
    version = "mlp"
)
