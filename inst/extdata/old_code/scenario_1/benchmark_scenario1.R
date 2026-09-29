# get benchmarks
algorithms <- c("mae", "lejepa", "vicreg", "btwins", "supcon")

# get samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
# get class labels
labels_emb <- sits_labels(samples_v13)
names(labels_emb) <- c(1:length(labels_emb))


results <- purrr::map(algorithms, function(algo){
    emb_class_dir <- paste0("cerrado_emb_",algo,"_tcnn_2018/",
                            "cerrado_emb_",algo,"_tcnn_2018_class")
    data_dir <- file.path(base_dir, emb_class_dir)
    print(data_dir)
    cube_class <- sits_cube(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        data_dir = data_dir,
        labels = labels_emb,
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
    file = "~/sitsfm/inst/extdata/cerrado_models/benchmark_scenario1_new.xlsx")
)
