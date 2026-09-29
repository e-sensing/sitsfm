# get samples
samples_class <- sits_from_parquet("~/hugging_face/samples_cerrado/labelled_samples_cerrado.parquet")
# get class labels
labels <- sits_labels(samples_class)
labels <- c(labels, "Urban_Area")
names(labels) <- c(1:length(labels))

validation_data <- sits_from_parquet("~/hugging_face/samples_cerrado/validation_data_2018.parquet")
sits_view(validation_data)
# get banchmarks
algorithms <- c("mae", "lejepa", "vicreg", "btwins", "supcon")

base_dir <- "/Volumes/KINGSTON/sitsfm/scenario_2/"
results <- purrr::map(algorithms, function(algo){
    algo_dir <- paste0("cerrado_emb_",algo,"_tcnn_2024")
    class_dir <- paste0("cerrado_emb_",algo,"_tcnn_2024_class")
    data_dir <- file.path(base_dir, algo_dir, class_dir)
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
    file = "~/sitsfm/inst/extdata/cerrado_models/benchmark_combined.xlsx")
)
