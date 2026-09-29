#
# Generate encoders using self-supervised learning
#
library(sits)
#
# Create user directory to save encoders
#
user_dir <- "./data/encoders"
dir.create(user_dir, recursive = TRUE)
#
# Read samples for the SSL training from 2017 to 2024 from Hugging Face
#
pretrain_samples <- sits_from_hf(
    repo = "e-sensing/samples_cerrado",
    file = "samples_cerrado_2017_2024_pretrain.parquet",
    type = "dataset"
)
#
# Create and save MAE encoder
#
ssl_mae_model <- sits_pre_train(
    samples = pretrain_samples,
    rl_method = sits_ssl_mae(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 2048,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(ssl_mae_model, file.path(user_dir, "ssl_mae_tcnn_model_2017_2024.rds"))
#
# Create and save LeJEPA encoder
#
ssl_lejepa_model <- sits_pre_train(
    samples = pretrain_samples,
    rl_method = sits_ssl_lejepa(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 2048,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(ssl_lejepa_model, file.path(user_dir, "ssl_lejepa_tcnn_model_2017_2024.rds"))
#
# Create and save VICReg encoder
#
ssl_vicreg_model <- sits_pre_train(
    samples = pretrain_samples,
    rl_method = sits_ssl_vicreg(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 2048,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(ssl_vicreg_model, file.path(user_dir, "ssl_vicreg_tcnn_model_2017_2024.rds"))
#
# Create and save Barlow Twins encoder
#
ssl_btwins_model <- sits_pre_train(
    samples = pretrain_samples,
    rl_method = sits_ssl_barlow_twins(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 2048,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(ssl_btwins_model, file.path(user_dir, "ssl_btwins_tcnn_model_2017_2024.rds"))
