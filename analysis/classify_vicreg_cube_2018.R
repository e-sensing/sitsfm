# Example of embeddings cube classification using VICReg encoder
#
library(sits)
#
#  1. Load the embeddings cube
#
#
vicreg_cube_2018_dir <- "./data/embeddings/embeddings/vicreg/emb_2018"
dir.create(vicreg_cube_2018_dir)
#
vicreg_cube_2018 <- sits_from_hf(
    repo = "e-sensing/cerrado_emb_ssl_vicreg_tcnn_2018",
    type = "dataset",
    output_dir = vicreg_cube_2018_dir
)
#
# 2. Get VICReg encoder
#
vicreg_encoder <- sits_from_hf(
    repo = "e-sensing/encoders_cerrado",
    file = "ssl_vicreg_tcnn_model_2017_2024.rds",
    type = "model"
)
#
# 3. Load the samples
#
labelled_samples <- sits_from_hf(
    repo = "e-sensing/samples_cerrado",
    file = "labelled_samples_cerrado.parquet",
    type = "dataset"
)
#
# 4. Recover the cerrado limits
#
cerrado_limits <- "./inst/extdata/cerrado_limits/cerrado-regions-bdc-md.gpkg"
#
#  5. Recover validation data
#
validation_data <- sits_from_hf(
    repo = "e-sensing/samples_cerrado",
    file = "validation_data_2018.parquet",
    type = "dataset"
)
#
#  6. Loop in fraction of samples
#
fractions <- c(0.05, 0.1, 0.15, 0.20, 0.25, 0.5)

results <- purrr::map(fractions, function(frac){
    labelled_samples_red <- sits_sample(labelled_samples, frac = frac)
    #
    # Encode the samples
    #
    samples_enc <- sits_encode(
        data = labelled_samples_red,
        encoder = vicreg_encoder,
        multicores = 8,
        gpu_memory = 16,
        batch_size = 512,
        verbose = TRUE
    )
    #
    # Create a directory to store results
    #
    dest_dir <- paste0("./data/results/vicreg/vicreg_2018_class_", round(frac,2))
    dir.create(dest_dir, recursive = TRUE)
    #
    # Build an MLP model for classification
    #
    mlp_model <- sits_train(
        samples = samples_enc,
        ml_method = sits_mlp(
            min_delta = 0.005,
            epochs = 150,
            batch_size = 128,
            verbose = TRUE
        )
    )
    #
    # Generate a Probability cube
    #
    #
    cube_probs <- sits_classify(
        data = vicreg_cube_2018,
        ml_model = mlp_model,
        roi = cerrado_limits,
        memsize = 12,
        multicores = 6,
        gpu_memory = 12,
        batch_size = 4096,
        output_dir = dest_dir,
        version = paste0("version-", round(frac,2))
    )
    #
    # Produce a smoothed cube
    #
    cube_smooth <- sits_smooth(
        cube = cube_probs,
        memsize = 30,
        multicores = 10,
        gpu_memory = 12,
        batch_size = 4096,
        output_dir = dest_dir,
        version = paste0("version-", round(frac,2))
    )
    #
    # Produce a classification map
    #
    cube_class <- sits_label_classification(
        cube_smooth,
        memsize = 32,
        multicores = 8,
        output_dir = dest_dir,
        version = paste0("version-", round(frac,2))
    )
    #
    #  Measure accuracy
    #
    acc <- sits_accuracy(
        data = cube_class,
        validation = validation_data,
        method = "pixel"
    )
    acc$name <- paste0("VICReg_", round(frac,2))
    # include accuracy in results list
    acc
}
)

#
# 14.Save to xlsx file
#
sits_to_xlsx(
    results,
    file = "./data/benchmarks_2018/acc_vicreg_005.xlsx"
)

