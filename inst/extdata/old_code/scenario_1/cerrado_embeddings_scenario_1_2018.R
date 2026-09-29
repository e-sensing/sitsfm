# Generate embeddings for Cerrado 2018 cube
# for selected tiles
#
# Base directory for data access
# Replace as appropriate for reproducibility
#
library(sits)
Sys.setenv("SITS_DOCUMENTATION_MODE" = "FALSE")

# --- MAE
source("cerrado_mae_scenario1_2018.R", echo = TRUE)

# --- LEJEPA
source("cerrado_lejepa_scenario1_2018.R", echo = TRUE)

# --- VICREG
source("cerrado_vicreg_scenario1_2018.R", echo = TRUE)

# --- BTWINS
source("cerrado_btwins_scenario1_2018.R", echo = TRUE)

# -- SUPCON
source("cerrado_supcon_scenario1_2018.R", echo = TRUE)
