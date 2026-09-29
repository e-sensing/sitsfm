# get samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
# get class labels
labels <- sits_labels(samples_v13)
names(labels) <- c(1:length(labels))

cerrado_class_v14_tiles <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_lucc_2024_tiles/",
    labels = labels,
    bands = "class",
    version = "v14a"
)
samples_per_class <- c(
    "Annual_Crop" = 2000,
    "Cerradao" = 2000,
    "Cerrado" = 2000,
    "Mangrove" = 500,
    "Nat_NonVeg" = 500,
    "Open_Cerrado" = 2000,
    "Pasture" = 2000,
    "Perennial_Crop" = 1500,
    "Silviculture" = 1500,
    "Sugarcane" = 1500,
    "Water" = 500
)
samples_bench <- sits_stratified_sampling(
    cube = cerrado_class_v14_tiles,
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
# get banchmarks
algorithms <- c("mae", "lejepa", "vicreg", "btwins", "supcon")

results <- purrr::map(algorithms, function(algo){
    data_dir <- paste0("/Volumes/KINGSTON/sitsfm/cerrado_emb_",algo,
                       "_tcnn_2024_class")
    print(data_dir)
    cube_class <- sits_cube(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        data_dir = data_dir,
        labels = labels,
        bands = "class",
        version = "v13"
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
        file = "~/sitsfm/inst/extdata/cerrado_models/benchmark.xlsx")
)
