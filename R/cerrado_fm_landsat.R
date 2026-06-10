# copy the Brazil Data Cube for the Cerrado
#
#
#
library(sits)

## STEP 1 - Create a regular data cube for the Cerrado
# get the limits of the Cerrado
cerrado_limits <- sf::st_read("./inst/extdata/cerrado_limits/cerrado-regions-bdc-md.gpkg")

# define Cerrado cube in BDC
#
bdc_cerrado_2017_2018 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    roi = cerrado_limits,
    start_date = "2017-01-01",
    end_date = "2018-12-31"
)

# select bands in BDC
bdc_cerrado <- sits_select(
    bdc_cerrado_2017_2018,
    bands = c("BLUE", "GREEN", "RED", "NIR08", "SWIR16", "SWIR22", "CLOUD")
)
# copy BDC files to local disk
bdc_cerrado_local <- sits_cube_copy(
    cube = bdc_cerrado,
    output_dir = "~/sitsfm/inst/extdata/cerrado_bdc/"
)
# create a regular data cube
bdc_cerrado_reg <- sits_regularize(
    cube = bdc_cerrado_local,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg/",
    period = "P1M",
    res = 30,
    roi = cerrado_limits,
    multicores = 8,
    progress = TRUE
)

## STEP 2 - Self-supervised learning with MAE and LTAE
# retrieve samples for the entire Cerrado
samples_cerrado_v12b <- readRDS("./inst/extdata/cerrado_samples/samples-cer-v12a.rds")

# retrieve the lables of the sample
labels <- sits_labels(samples_cerrado_v12b)
names(labels) <- paste(seq_along(labels))

# retrieve classified cube for stratified sampling
cerrado_class <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "./inst/extdata/cerrado_class_120m/",
    labels = labels,
    version = "r_60m",
    bands = "class"
)

# define number of samples per class
samples_per_class <- c(
    "Annual_Crop" = 25000,
    "Cerradao" = 25000,
    "Cerrado" = 25000,
    "Mangrove" = 1000,
    "Nat_NonVeg" = 1000,
    "Open_Cerrado" = 25000,
    "Pasture" = 25000,
    "Perennial_Crop" = 5000,
    "Silviculture" = 10000,
    "Sugarcane" = 15000,
    "Water" = 5000
)

# retrieve the samples to be used for SSL
samples_ssl <- sits_stratified_sampling(
    cube = cerrado_class,
    samples_per_class = samples_per_class,
    multicores = 8,
    memsize = 24
)
# save the samples
saveRDS(samples_ssl, "~/sitsfm/inst/extdata/cerrado_samples/samples_ssl.rds")

samples_ssl_ts <- sits_get_data(
    cube = bdc_cerrado_reg,
    samples = samples_ssl,
    multicores = 8
)

saveRDS(samples_ssl_ts, "~/sitsfm/inst/extdata/cerrado_samples/samples_ssl_ts.rds")

mae_model <- sits_pre_train(
    samples = samples_ssl_ts,
    encoder_method = sits_mae(
        embedding_dim = 32,
        encoder_model = sits_lighttae(),
        mask_ratio = 0.5
    )
)
cerrado_embeddings_2017_2018 <- sits_encode(
    data = bdc_cerrado_reg,
    encoder = mae_model,
    memsize = 16,
    multicores = 2,
    gpu_memory = 16,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_2017_2018/"
)

cerrado_samples <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")

cerrado_samples_emb <- sits_encode(
    data = cerrado_samples,
    encoder = mae_model,
    memsize = 32,
    multicores = 4,
    gpu_memory = 16,
    batch_size = 2^18
)

saveRDS(cerrado_samples_emb, "~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a-emb.rds")

emb_rfor_model <- sits_train(
    samples =  cerrado_samples_emb,
    ml_method = sits_rfor()
)

cube_emb_015009 <- dplyr::filter(
    cerrado_embeddings_2017_2018,
    .data[["tile"]] == "015009"
)
cube_emb_015009_probs <- sits_classify(
    data = cube_emb_015009,
    ml_model = emb_rfor_model,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_rfor/",
    version = "rfor"
)

cube_emb_015009_smooth <- sits_smooth(
    cube = cube_emb_015009_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_rfor/",
    version = "rfor"
)
cube_emb_015009_class <- sits_label_classification(
    cube = cube_emb_015009_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_class_rfor/",
    version = "rfor"
)

cerrado_embeddings_2017_2018 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_emb_2017_2018/"
)
plot(cerrado_embeddings_2017_2018, tile = "017004", red = "E2", green = "E1", blue = "E3")

