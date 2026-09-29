#
# Generate embedding for 2018 Cerrado data cube
#
#
library(sits)
#
# 1. Create a directory to store data cube
#
reg_data_dir <- "./data/cubes/cerrado_cube_reg_2018"
dir.create(reg_data_dir, recursive = TRUE)
#
# 2. Download the 2018 data cube
#
cerrado_cube_reg_2018 <- sits_from_hf(
    repo = "e-sensing/cerrado_cube_reg_2018",
    type = "dataset",
    output_dir = reg_data_dir
)
#
# 2. Generate MAE embedding
#
# 2.1 Retrieve the MAE encoder
#
mae_encoder <- sits_from_hf(
    repo = "e-sensing/encoders_cerrado",
    file = "ssl_mae_tcnn_model_2017_2024.rds",
    type = "model"
)
#
#  2.2 Define the output dir
#
mae_emb_dir <- "./data/embeddings/mae_emb_2018"
dir.create(mae_emb_dir, recursive = TRUE)
#
#  2.3 Generate the embeddings cube
#
mae_embedding <- sits_encode(
    data = cerrado_cube_reg_2018,
    encoder = mae_encoder,
    memsize = 12,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 4096,
    output_dir = mae_emb_dir
)
#
#  3. Generate VICREG embedding
#
#  3.1 Retrieve the  encoder
#
vicreg_encoder <- sits_from_hf(
    repo = "e-sensing/encoders_cerrado",
    file = "ssl_vicreg_tcnn_model_2017_2024.rds",
    type = "model"
)
#
#  3.2 Define the output dir
#
vicreg_emb_dir <- "./data/embeddings/vicreg_emb_2018"
dir.create(vicreg_emb_dir, recursive = TRUE)
#
# 3.3 Generate the embeddings cube
#
vicreg_embedding <- sits_encode(
    data = cerrado_cube_reg_2018,
    encoder = vicreg_encoder,
    memsize = 12,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 4096,
    output_dir = vicreg_emb_dir
)
#
#  4. Generate LeJEPA embedding
#
#  4.1 Retrieve the  encoder
lejepa_encoder <- sits_from_hf(
    repo = "e-sensing/encoders_cerrado",
    file = "ssl_lejepa_tcnn_model_2017_2024.rds",
    type = "model"
)
#
#  4.2 Define the output dir
#
lejepa_emb_dir <- "./data/embeddings/lejepa_emb_2018"
dir.create(lejepa_emb_dir, recursive = TRUE)
#
#  4.3 Generate the embeddings cube
#
lejepa_embedding <- sits_encode(
    data = cerrado_cube_reg_2018,
    encoder = lejepa_encoder,
    memsize = 12,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 4096,
    output_dir = lejepa_emb_dir
)
#
#  5. Generate Barlow Twins embedding
#
#  5.1 Retrieve the  encoder
btwins_encoder <- sits_from_hf(
    repo = "e-sensing/encoders_cerrado",
    file = "ssl_btwins_tcnn_model_2017_2024.rds",
    type = "model"
)
#
#  5.2 Define the output dir
#
btwins_emb_dir <- "./data/embeddings/btwins_emb_2018"
dir.create(btwins_emb_dir, recursive = TRUE)
#
#  5.3 Generate embeddings cube
btwins_embedding <- sits_encode(
    data = cerrado_cube_reg_2018,
    encoder = btwins_encoder,
    memsize = 12,
    multicores = 6,
    gpu_memory = 12,
    batch_size = 4096,
    output_dir = btwins_emb_dir
)
