validation_data <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/validation_data_2024.rds")


library(sits)
# get samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
# get class labels
labels <- sits_labels(samples_v13)
labels <- c(labels, "Urban_Area")
names(labels) <- c(1:length(labels))


base_dir <- "/Volumes/KINGSTON/sitsfm/scenario_2"
# get benchmarks
algorithms <- c("mae", "lejepa", "vicreg", "btwins", "supcon")

results <- purrr::map(algorithms, function(algo){
    data_dir <- file.path(base_dir,
                          paste0("cerrado_emb_",algo,"_tcnn_2024"),
                          paste0("cerrado_emb_",algo,"_tcnn_2024_class")
    )
    print(data_dir)
    cube_class <- sits_cube(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        data_dir = data_dir,
        labels = labels,
        bands = "class",
        version = "v1"
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

data_dir <- "/Volumes/KINGSTON/sitsfm/cerrado_alphaearth/2024/tiles"

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

data_dir <- "/Volumes/KINGSTON/sitsfm/cerrado_lucc_2024"

lucc_2024_class <- sits_cube(
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
    data = lucc_2024_class,
    validation = validation_data,
    method = "pixel"
)
acc_lucc$name <- "TCNN"
results[[length(results) + 1 ]] <- acc_lucc

# save to xlsx file
sits_to_xlsx(
    results,
    file = "~/sitsfm/inst/extdata/cerrado_models/benchmark_2024.xlsx"
)
