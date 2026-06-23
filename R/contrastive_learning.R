samples_cerrado_v12b <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v12a.rds")

labels <- sits_labels(samples_cerrado_v12b)
names(labels) <- paste(seq_along(labels))

class_dir <-  "~/sitsfm/inst/extdata/cerrado_class_120m/"

cerrado_class <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = class_dir,
    labels = labels,
    version = "r-120m",
    bands = "class"
)

samples_ssl_base <- sits_stratified_sampling(
    cube = cerrado_class,
    samples_per_class = 1000,
    overhead = 1.0,
    multicores = 6,
    memsize = 36
)
cerrado_cube_reg <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg/"
)

samples_ssl <- sits_get_data(
    cube = cerrado_cube_reg,
    samples = samples_ssl_base,
    multicores = 8
)

ssl_model <- sits_pre_train(
    samples = samples_ssl,
    encoder_method = sits_contrastive_learning(
        embedding_dim = 32,
        triplet_smp_method = "random",
        encoder_model = sits_lighttae()
    )
)
