# define Cerrado cube in BDC
#
bdc_cerrado_2023_2024 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    tiles = c("014012", "017004", "009010", "013014", "015005", "015009"),
    bands = c("BLUE", "GREEN", "RED", "NIR08", "SWIR16", "SWIR22"),
    start_date = "2023-01-01",
    end_date = "2024-12-31"
)

# copy BDC cube to local files
cube_cerrado_2023_2024 <- sits_cube_copy(
    cube = bdc_cerrado_2023_2024,
    multicores = 10,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_bdc_2024/"
)
# include sits_regularize
#
cube_cerrado_2023_2024_reg <- sits_regularize(
    cube = cube_cerrado_2023_2024,
    period = "P1M",
    res = 30,
    roi = cerrado_limits,
    multicores = 10,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg_2024/"
)
# recover sits_regular cube
cube_cerrado_2023_2024_reg <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_reg_2024/"
)
# recover contrastive learning model
cl_model <- readRDS("~/sitsfm/inst/extdata/cerrado_models/cl_model.rds")

# recover Barlow twins model
bt_model <- readRDS("~/sitsfm/inst/extdata/cerrado_models/btwins_model.rds")

cube_cerrado_2023_2024_emb_cl <- sits_encode(
    data = cube_cerrado_2023_2024_reg,
    encoder = cl_model,
    memsize = 10,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 4096,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_cl_2024/"
)

cube_cerrado_2023_2024_emb_cl <- sits_encode(

)

# recover embeddings
cube_cerrado_2023_2024_emb_cl <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_cl_2024/"
)

# retrieve the samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")

# encode the samples using the CL model
encoded_samples_cl <- sits_encode(
    data = samples_v13,
    encoder = cl_model,
    multicores = 8,
    gpu_memory = 20,
    batch_size = 4096
)

mlp_model <- sits_train(
    encoded_samples_cl,
    ml_method = sits_mlp()
)

# recover MLP model from 2018
saveRDS(mlp_model, "~/sitsfm/inst/extdata/cerrado_models/mlp_model_emb.rds")

cube_cerrado_2023_2024_emb_cl_probs <- sits_classify(
    data = cube_cerrado_2023_2024_emb_cl,
    ml_model = mlp_model,
    memsize = 20,
    multicores = 10,
    gpu_memory = 20,
    batch_size = 4096,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_cl_2024_class/"
)

cube_cerrado_2023_2024_emb_cl_smooth <- sits_smooth(
    cube = cube_cerrado_2023_2024_emb_cl_probs,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_cl_2024_class/",
    version = "mlp"
)
cube_cerrado_2023_2024_emb_cl_class <- sits_label_classification(
    cube_cerrado_2023_2024_emb_cl_smooth,
    memsize = 32,
    multicores = 8,
    output_dir = "/Volumes/KINGSTON/sitsfm/cerrado_cube_emb_cl_2024_class/",
    version = "mlp"
)

