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

samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
# get class labels
labels <- sits::sits_labels(samples_v13)
names(labels) <- c(1:length(labels))


validation_data <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/validation_data_2018.rds")

validation_data <- dplyr::filter(
    validation_data, !(label %in% c("Mangrove", "Nat_NonVeg")))

base_dir <- "/Volumes/KINGSTON/sitsfm/scenario_1"
# get benchmarks
algorithms <- c("mae", "lejepa", "vicreg", "btwins", "supcon")

results <- purrr::map(algorithms, function(algo){
    data_dir <- file.path(base_dir,
                          paste0("cerrado_emb_",algo,"_tcnn_2018"),
                          paste0("cerrado_emb_",algo,"_tcnn_2018_class")
    )
    print(data_dir)
    cube_class <- sits_cube(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        data_dir = data_dir,
        labels = labels,
        bands = "class",
        version = "mlp"
    )
    # accuracy mae
    acc <- sits_accuracy(
        data = cube_class,
        validation = validation_data,
        method = "pixel"
    )
    acc$name <- toupper(algo)
    acc
})
## Alpha Earth

data_dir <- "/Volumes/KINGSTON/sitsfm/cerrado_alphaearth/2018/tiles"

alpha_earth_class <- sits_cube(
    source = "GOOGLE",
    collection = "ALPHAEARTH",
    data_dir = data_dir,
    labels = labels,
    bands = "class",
    version = "v3",
    multicores = 6,
    memsize = 12
)
# accuracy mae
acc_ae <- sits_accuracy(
    data = alpha_earth_class,
    validation = validation_data,
    method = "pixel"
)
acc_ae$name <- "AlphaEarth"
results[[length(results) + 1 ]] <- acc_ae

## Alpha Earth

data_dir <- "/Volumes/KINGSTON/sitsfm/cerrado_lucc_2018"

lucc_2018_class <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = data_dir,
    labels = labels,
    bands = "class",
    version = "v13a",
    multicores = 6,
    memsize = 12
)
# accuracy mae
acc_lucc <- sits_accuracy(
    data = lucc_2018_class,
    validation = validation_data,
    method = "pixel"
)
acc_lucc$name <- "TCNN-v13"
results[[length(results) + 1 ]] <- acc_lucc


# save to xlsx file
sits_to_xlsx(
    results,
    file = "~/sitsfm/inst/extdata/cerrado_models/benchmark_scenario1_2018_reduced.xlsx"
)
