# Generate embeddings for Cerrado 2018 cube
# for selected tiles
#
# Base directory for data access
# Replace as appropriate for reproducibility
#
library(sits)
Sys.setenv("SITS_DOCUMENTATION_MODE" = "FALSE")

algorithm <- "lejepa"
algo_prefix <- "ssl"
encoding_period  <- "2017_2024"
scenario  <- "scenario_1"
target_year <-  "2018"

base_dir <- "/Volumes/KINGSTON/sitsfm/"
data_dir <- file.path(base_dir, paste0("cerrado_cube_reg_", target_year, "/"))


models_dir <- "~/sitsfm/inst/extdata/cerrado_models/"
encoder_file <- file.path(models_dir, paste0(algo_prefix, "_", algorithm, "_tcnn_model_",
                       encoding_period, ".rds"))

# recover embedding model
encoder <- readRDS(encoder_file)
# embeddings dir for MAE
target_dir <- paste0("cerrado_emb_", algorithm, "_tcnn_", target_year)
emb_dir <- file.path(base_dir, paste0(scenario, "/", target_dir))
dest_dir <- file.path(emb_dir, paste0(target_dir, "_class"))

# Check if directory exists; if not, create it
if (!dir.exists(emb_dir)) {
    dir.create(emb_dir, recursive = TRUE)
}
# Check if directory exists; if not, create it
if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
}
tiles_bdc <- c(
    "017004", "015005", "015006",
    "015007", "014008", "015009",
    "009010", "013010", "013012",
    "014012", "011013", "013014"
)

bands_landsat <- c("BLUE", "GREEN", "RED", "NIR08", "SWIR16", "SWIR22")
source <- "BDC"
collection <- "LANDSAT-OLI-16D"

# # Samples version 13 (collected only in the 2018 cube)
#
samples <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")

# Generate Embeddings Cube

cube_input <- sits::sits_cube(
    source = source,
    collection = collection,
    tiles = tiles_bdc,
    data_dir = data_dir,
    multicores = 6
)

cube_emb <- sits::sits_encode(
    data = cube_input,
    encoder = encoder,
    memsize = 12,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 16384,
    output_dir = emb_dir
)
# Classify embeddings cube
#
#
# encode samples
samples_emb <- sits::sits_encode(
    data = samples,
    encoder = encoder,
    multicores = 12,
    gpu_memory = 16,
    batch_size = 512
)

mlp_validation <- sits_kfold_validate(
    samples_emb,
    folds = 5,
    ml_method = sits::sits_mlp(
        min_delta = 0.005,
        epochs = 150,
        batch_size = 128,
        verbose = TRUE
    ),
    multicores = 5,
    gpu_memory = 12,
    batch_size = 1024
)

# recover sits_regular cube
cube_emb <- sits::sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = emb_dir,
    multicores = 6,
    memsize = 12
)

#
# MLP classifier
#
mlp_model <- sits::sits_train(
    samples_emb,
    ml_method = sits::sits_mlp(
        min_delta = 0.005,
        epochs = 150,
        batch_size = 128,
        verbose = TRUE
    )
)
# Probability cube
cube_probs <- sits::sits_classify(
    data = cube_emb,
    ml_model = mlp_model,
    memsize = 12,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 12000,
    output_dir = dest_dir,
    verbose = TRUE,
    version = "mlp"
)
# Smoothed cube
cube_smooth <- sits::sits_smooth(
    cube = cube_probs,
    memsize = 30,
    multicores = 10,
    output_dir = dest_dir,
    version = "mlp"
)
# Classification map
cube_class <- sits::sits_label_classification(
    cube_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = dest_dir,
    version = "mlp"
)
