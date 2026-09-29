# Read samples for the year 2017 to 2024
#
library(sits)
samples_2017_2024 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-2017-2024-pretrain.rds")

samples_2017_2024 <- sits_select(
    data = samples_2017_2024,
    bands = c("BLUE", "GREEN", "RED", "NIR08", "SWIR16", "SWIR22")
)


# create MAE foundational model
ssl_mae_model <- sits_pre_train(
    samples = samples_2017_2024,
    encoder_method = sits_ssl_mae(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 512,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(ssl_mae_model, "~/sitsfm/inst/extdata/cerrado_models/ssl_mae_tcnn_model_2017_2024.rds")

# create LeJEPA foundational model
ssl_lejepa_model <- sits_pre_train(
    samples = samples_2017_2024,
    encoder_method = sits_ssl_lejepa(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 512,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(ssl_lejepa_model, "~/sitsfm/inst/extdata/cerrado_models/ssl_lejepa_tcnn_model_2017_2024.rds")

# create VicREG foundational model
ssl_vicreg_model <- sits_pre_train(
    samples = samples_2017_2024,
    encoder_method = sits_ssl_vicreg(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 512,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(ssl_vicreg_model, "~/sitsfm/inst/extdata/cerrado_models/ssl_vicreg_tcnn_model_2017_2024.rds")

# create Barlow Twins foundational model
btwins_model <- sits_pre_train(
    samples = samples_2017_2024,
    encoder_method = sits_barlow_twins(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 512,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(btwins_model, "~/sitsfm/inst/extdata/cerrado_models/btwins_tcnn_model_2017_2024.rds")


# create Supervised Contrastive Learning foundational model
supcon_model <- sits_pre_train(
    samples = samples_2017_2024,
    encoder_method = sits_contrastive_learning(
        embedding_dim = 64,
        epochs = 150,
        batch_size = 512,
        encoder_model = sits_tempcnn(),
        verbose = TRUE
    )
)
saveRDS(supcon_model, "~/sitsfm/inst/extdata/cerrado_models/supcon_tcnn_model_2017_2024.rds")
