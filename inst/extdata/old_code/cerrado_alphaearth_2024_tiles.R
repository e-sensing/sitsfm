# Save tiles from the ALPHA EARTH 2018 map


# base directory
base_dir <- "/Volumes/KINGSTON/sitsfm/"

# tiles
tiles_bdc <- c(
    "017004", "015005", "015006",
    "015007", "014008", "015009",
    "009010", "013010", "013012",
    "014012", "011013", "013014"
)

# retrive classified map for the Cerrado
lucc_map_dir <- "cerrado_alphaearth/2024/"
version <- "v3"
# temp directory for storing alpha earth
temp_dir <- "temp"
# produce a new data cube only for the selected tiles
tiles_dir <- "cerrado_alphaearth/2024/tiles/"
# path to directory
full_path_tiles_dir <- file.path(base_dir, tiles_dir)
# Check if directory exists; if not, create it
if (!dir.exists(full_path_tiles_dir)) {
    dir.create(full_path_tiles_dir, recursive = TRUE)
}
# start and end date
start_date <- "2024-01-01"
end_date   <- "2024-12-31"
# source, collection, satellite, sensor
source <- "GOOGLE"
collection <- "ALPHAEARTH"
satellite <- "SENTINEL-2-L2A"
sensor <- "ALPHAEARTH"

# labels
# get samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
# get class labels
labels <- sits::sits_labels(samples_v13)
names(labels) <- c(1:length(labels))

# retrive classified map for the Cerrado
cube_class <- sits::sits_cube(
    source = source,
    collection = collection,
    data_dir = file.path(base_dir, lucc_map_dir),
    labels = labels,
    bands = "class",
    version = version,
    multicores = 6,
    memsize = 12
)
# produce a new data cube only for the selected tiles
# Copy slide by bounding boxes
cube_lst <- purrr::map(tiles_bdc, function(tile){
    roi <- sits::sits_tiles_to_roi(tile, "BDC_MD_V2")
    part <- sits::sits_cube_copy(
        cube = cube_class,
        roi = roi,
        res = 30,
        output_dir = file.path(base_dir, temp_dir)
    )
    old_name <- part$file_info[[1]]$path
    new_name <- file.path(
        base_dir,
        tiles_dir,
        paste0(source, "_", collection, "_", tile,"_", start_date, "_",
               end_date, "_class_", version, ".tif")
    )
    file.rename(from = old_name, to = new_name)
    part$file_info[[1]]$path <- new_name
    part$tile <- tile
    part
})
alpha_earth_cube <- dplyr::bind_rows(cube_lst)

# crop Alpha Earth to cerrado boundaries.
cerrado_limits <- sf::st_read("~/sitsfm/inst/extdata/cerrado_limits/cerrado-regions-bdc-md.gpkg")

cut_dir <- file.path(base_dir, "tmp/alpha")
if (!dir.exists(cut_dir)) {
    dir.create(cut_dir, recursive = TRUE)
}

alpha_earth_tiles <- sits_cube_copy(
    cube = alpha_earth_cube,
    roi = cerrado_limits,
    multicores = 6,
    output_dir = cut_dir
)
validation_data <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/validation_data_2024.rds")

validation_data_simplified <- dplyr::filter(
    validation_data, !(label %in% c("Mangrove", "Nat_NonVeg"))
)
acc <- sits_accuracy(
    data = alpha_earth_tiles,
    validation = validation_data_simplified,
    method = "pixel"
)
acc$name <- "AlphaEarth"
# save to xlsx file
sits_to_xlsx(
    acc,
    file = "~/sitsfm/inst/extdata/cerrado_models/benchmark_alphaearth_2018.xlsx")
)
