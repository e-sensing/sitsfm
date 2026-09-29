# Generate embeddings for Cerrado 2018 cube
# for selected tiles
#
# Base directory for data access
# Replace as appropriate for reproducibility
#
library(sits)
Sys.setenv("SITS_DOCUMENTATION_MODE" = "FALSE")

algorithm <- "supcon"
encoding_period  <- "2017_2024"
scenario  <- "scenario_2"
target_year <-  "2024"

base_dir <- "/Volumes/KINGSTON/sitsfm/"
data_dir <- file.path(base_dir, paste0("cerrado_cube_reg_", target_year, "/"))


models_dir <- "~/sitsfm/inst/extdata/cerrado_models/"
encoder_file <- file.path(models_dir, paste0(algorithm, "_tcnn_model_",
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

# # Samples version 13 (collected only in the 2018 cube)
#
samples <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")

# Generate Embeddings Cube
emb_cube <- sitsfm_generate_embeddings(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        data_dir = data_dir,
        tiles = tiles_bdc,
        emb_model = mae_model,
        emb_dir = emb_dir,
        memsize = 16,
        multicores = 8,
        gpu_memory = 16,
        batch_size = 2^16
)
# Classify embeddings cube
#
#
class_emb_cube <- sitsfm_embbedings_classification(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    samples = samples,
    encoder = encoder,
    emb_dir - emb_dir,
    dest_dir = dest_dir,
    version = version,
    multicores = 6,
    memsize = 12,
    gpu_memory = 12,
    train_batch_size = 512,
    class_batch_size = 2^16
)
