# Generate embeddings for Cerrado 2024 cube
# for selected tiles
#
# Base directory for data access
# Replace as appropriate for reproducibility
#
library(sits)
Sys.setenv("SITS_DOCUMENTATION_MODE" = "FALSE")
base_dir <- "/Volumes/KINGSTON/sitsfm/"

# MAE
source("~/sitsfm/scripts/cerrado_mae_scenario1_2018.R", echo = TRUE)

# LeJEPA
source("~/sitsfm/scripts/cerrado_lejepa_scenario1_2018.R", echo = TRUE)

# --- VICREG
source("~/sitsfm/scripts/cerrado_vicreg_scenario1_2018.R", echo = TRUE)

# --- BTWINS
source("~/sitsfm/scripts/cerrado_btwins_scenario1_2018.R", echo = TRUE)

# -- SUPCON
source("~/sitsfm/scripts/cerrado_supcon_scenario1_2018.R", echo = TRUE)
