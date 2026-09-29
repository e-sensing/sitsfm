# Produce Landsat 1-month Cerrado regular data cube
# for selected tiles
#
# Base directory for data access
# Replace as appropriate for reproducibility
#
base_dir <- "/Volumes/KINGSTON/sitsfm/"

# tiles
tiles_bdc <- c(
    "017004", "015005", "015006",
    "015007", "014008", "015009",
    "009010", "013010", "013012",
    "014012", "011013", "013014"
)
# define Cerrado cube in BDC
#
#
bdc_cerrado_2023_2024 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    tiles = tiles,
    bands = c("BLUE", "GREEN", "RED", "NIR08", "SWIR16", "SWIR22", "CLOUD"),
    start_date = "2023-01-01",
    end_date = "2024-12-31"
)

# copy BDC cube to local files
dest_dir <- "cerrado_cube_bdc_2024/"
output_dir <- file.path(base_dir, dest_dir)

cube_cerrado_2023_2024 <- sits_cube_copy(
    cube = bdc_cerrado_2023_2024,
    multicores = 10,
    output_dir = output_dir
)
# define the limits of the cerrado
#
cerrado_limits <- sf::st_read("~/sitsfm/inst/extdata/cerrado_limits/cerrado-regions-bdc-md.gpkg")

# regularize the cube
dest_dir <- "cerrado_cube_reg_2024/"

cube_cerrado_2023_2024_reg <- sits_regularize(
    cube = cube_cerrado_2023_2024,
    period = "P1M",
    res = 30,
    roi = cerrado_limits,
    multicores = 10,
    output_dir = file.path(base_dir, dest_dir)
)
