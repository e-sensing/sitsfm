library(sits)

cerrado_limits <- sf::st_read("~/sitsfm/inst/extdata/cerrado_limits/cerrado-regions-bdc-md.gpkg")

base_dir <- "/Volumes/KINGSTON/sitsfm"

algo <- "supcon"

samples <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
labels <- sits_labels(samples)
names(labels) <- c(1:length(labels))

data_dir <- file.path(base_dir,"scenario_3", paste0("cerrado_emb_", algo, "_tcnn_2024"))
class_dir <- file.path(data_dir, paste0("cerrado_emb_", algo, "_tcnn_2024_class" ))

class_cube_emb <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = class_dir,
    bands = "class",
    labels = labels,
    version = "mlp",
    multicores = 4
)

tmp_dir <- file.path(base_dir, "/tmp/", algo)
# Check if directory exists; if not, create it
if (!dir.exists(tmp_dir)) {
    dir.create(tmp_dir, recursive = TRUE)
}

cube_copy <- sits_cube_copy(
    class_cube_emb,
    roi = cerrado_limits,
    output_dir = tmp_dir,
    multicores = 4
)

