#' @title Calculate accuracy for embeddings for 2018, compare with TempCNN and AlphaEarth
#'
#' @export
#'
#'
# get samples
year <- "2018"
base_dir <-  "/Volumes/KINGSTON/sitsfm"
emb_algoritms <- c("mae", "lejepa", "vicreg", "btwins", "supcon")
emb_dir <-  "cerrado_emb"
scenario_emb <-  "scenario_1"
version_emb <- "mlp"
lucc_dir <- "cerrado_lucc_2018/cerrado_lucc_2018_tiles"
version_tcnn <- "v14a"
use_alpha_earth <- TRUE
alpha_earth_dir <- file.path(base_dir, "cerrado_alphaearth/2018")
version_alpha <- "v1"

# If labels are NULL, use defaults
if (is.null(labels)) {
    samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
    # get class labels
    labels_emb <- sits::sits_labels(samples_v13)
    names(labels_emb) <- c(1:length(labels_emb))
}


# save to xlsx file
sits_to_xlsx(
    results,
    file = "~/sitsfm/inst/extdata/cerrado_models/benchmark_scenario1_2018_new.xlsx"
)
