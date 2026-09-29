# Generate embeddings for Cerrado 2018 cube
# for selected tiles
#
# Base directory for data access
# Replace as appropriate for reproducibility
#
library(sits)
Sys.setenv("SITS_DOCUMENTATION_MODE" = "FALSE")
base_dir <- "/Volumes/KINGSTON/sitsfm/"
data_dir <- file.path(base_dir, "cerrado_cube_reg_2018/")


# recover embedding model
ssl_mae_model <- readRDS("~/sitsfm/inst/extdata/cerrado_models/ssl_mae_tcnn_model_2017_2024.rds")
# embeddings dir for MAE
emb_dir <- file.path(base_dir, "scenario_1/cerrado_emb_mae_tcnn_2018/")

mae_emb_cube <- sitsfm_generate_embeddings(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        data_dir = data_dir,
        emb_model = mae_model,
        emb_dir = emb_dir,
        memsize = 16,
        multicores = 8,
        gpu_memory = 16,
        batch_size = 2^16
)


# recover sits_regular cube
cube_dir <- "cerrado_cube_reg_2018/"
cube_cerrado_2017_2018_reg <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    tiles = tiles_bdc,
    data_dir = file.path(base_dir, cube_dir)
)


# Generate the embeddings
#

cube_cerrado_2017_2018_emb_mae <- sits_encode(
    data = cube_cerrado_2017_2018_reg,
    encoder = mae_model,
    memsize = 12,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 4096,
    output_dir = file.path(base_dir, emb_dir)
)
# generate classification
#
# Samples version 13 (collected only in the 2018 cube)
#
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")

samples_emb_mae <- sits_encode(
    data = samples_v13,
    encoder = mae_model,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 1024
)

#
# MLP classifier
#
mlp_model <- sits_train(
    samples_emb_mae,
    ml_method = sits_mlp(
        min_delta = 0.005,
        epochs = 150,
        batch_size = 128,
        verbose = TRUE
    )
)
#
dest_dir <- "cerrado_emb_mae_tcnn_2018/cerrado_emb_mae_tcnn_2018_class"

# Probability cube
cube_cerrado_2017_2018_emb_mae_probs <- sits_classify(
    data = cube_cerrado_2017_2018_emb_mae,
    ml_model = mlp_model,
    memsize = 12,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 4096,
    output_dir = file.path(base_dir, dest_dir),
    version = "mlp"
)
# Smoothed cube
cube_cerrado_2017_2018_emb_mae_smooth <- sits_smooth(
    cube = cube_cerrado_2017_2018_emb_mae_probs,
    memsize = 30,
    multicores = 10,
    output_dir = file.path(base_dir, dest_dir),
    version = "mlp"
)
# Classification map
cube_cerrado_2017_2018_emb_mae_class <- sits_label_classification(
    cube_cerrado_2017_2018_emb_mae_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = file.path(base_dir, dest_dir),
    version = "mlp"
)
