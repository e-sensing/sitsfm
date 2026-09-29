library(sits)
# get samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
# get class labels
labels <- sits_labels(samples_v13)
labels <- c(labels, "Urban_Area")
names(labels) <- c(1:length(labels))

base_dir <- "/Volumes/KINGSTON/sitsfm/"
tiles_urban_dir <- "cerrado_lucc_2024/cerrado_lucc_2024_tiles_urban/"
cerrado_class_v14_tiles_urban <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = file.path(base_dir, tiles_urban_dir),
    labels = labels,
    bands = "class",
    version = "v1"
)
# samples per class - excludes stable classes
samples_per_class <- c(
    "Annual_Crop" = 2000,
    "Cerradao" = 2000,
    "Cerrado" = 2000,
    "Open_Cerrado" = 2000,
    "Pasture" = 2000,
    "Perennial_Crop" = 1500,
    "Silviculture" = 1500,
    "Sugarcane" = 1500
)
# get validation data for natural land covers
samples_bench <- sits_stratified_sampling(
    cube = cerrado_class_v14_tiles_urban,
    samples_per_class = samples_per_class,
    overhead = 1.0,
    multicores = 8,
    memsize = 32
)
validation_data <- sits_sf_to_tibble(
    samples_bench,
    start_date = "2023-01-01",
    end_date = "2024-12-31"
)
sits_view(validation_data)
# get begit nchmarks
algorithms <- c("mae", "lejepa", "vicreg", "btwins", "supcon")

results <- purrr::map(algorithms, function(algo){
    data_dir <- file.path(base_dir,
                          paste0("cerrado_emb_",algo,"_tcnn_2024/"),
                          paste0("cerrado_emb_",algo,"_tcnn_2024_class")
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
# save to xlsx file
sits_to_xlsx(
        results,
        file = "~/sitsfm/inst/extdata/cerrado_models/benchmark_urban.xlsx"
)
