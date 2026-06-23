cerrado_embeddings_2017_2018 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_2017_2018/"
)
plot(cerrado_embeddings_2017_2018, tile = "017004", red = "E2", green = "E1", blue = "E3")

cerrado_samples_v13a <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
cerrado_samples_emb <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a-emb.rds")

som_map <- sits_som_map(
    data = cerrado_samples_emb,
    grid_xdim = 15,
    grid_ydim = 15,
    distance = "euclidean",
    mode = "online"
)
som_eval <- sits_som_evaluate_cluster(som_map)
plot(som_eval)

all_samples <- sits_som_clean_samples(
    som_map = som_map,
    prior_threshold = 0.5,
    posterior_threshold = 0.5,
    keep = c("clean", "analyze", "remove"))

# Print the sample distribution based on evaluation
plot(all_samples)


mlp_model <- sits_train(
    samples = cerrado_samples_emb,
    ml_method = sits_mlp(layers = c(512, 512, 512),
                         dropout_rates = c(0.20, 0.30, 0.40),
                         optimizer = torch::optim_adamw,
                         opt_hparams = list(
                             lr = 0.001,
                             eps = 1e-08,
                             weight_decay = 1.0e-06
                         ),
                         epochs = 100L,
                         batch_size = 64,
                         validation_split = 0.2,
                         patience = 20L,
                         min_delta = 0.01,
                         seed = 03022024,
                         verbose = TRUE

    )
)
saveRDS(mlp_model, "~/sitsfm/inst/extdata/cerrado_models/mlp_model_emb.rds")

cube_emb_017004 <- dplyr::filter(
    cerrado_embeddings_2017_2018,
    .data[["tile"]] == "017004"
)
cube_emb_017004_probs <- sits_classify(
    data = cube_emb_017004,
    ml_model = mlp_model,
    memsize = 32,
    multicores = 8,
    gpu_memory = 18,
    batch_size = 2^18,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_mlp/",
    version = "mlp",
    verbose = TRUE
)

cube_emb_017004_smooth <- sits_smooth(
    cube = cube_emb_017004_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_mlp/",
    version = "mlp"
)
cube_emb_017004_class <- sits_label_classification(
    cube = cube_emb_017004_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_mlp/",
    version = "mlp"
)
