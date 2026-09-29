# Produce classified cerrado regular data cube
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
# get samples
# get class labels
labels_tc <- c(
    "1"  = "Natural Vegetation",
    "2"  = "Secondary Vegetation",
    "9"  = "Silviculture",
    "11" = "Pasture",
    "12" = "Perennial_Crop",
    "13" = "Sugarcane",
    "14" = "Annual_Crop_1_Cycle",
    "15" = "Annual_Crop_2_Cycles",
    "16" = "Mining",
    "17" = "Urban_Area",
    "20" = "Other Uses",
    "21" = "Other Built-up Areas",
    "22" = "Deforestation",
    "23" = "Water Bodies",
    "25" = "Not Observed"
)

# produce a new data cube only for the selected tiles
terra_class_dir <- "terra_class"
# retrieve terra class 2024
#
terra_class_2018 <- sits_cube(
    source = "BDC",
    collection = "SENTINEL-2-16D",
    data_dir = file.path(base_dir, terra_class_dir),
    labels = labels_tc,
    bands = "class",
    version = "30m",
    multicores = 8
)
tiles_terra_class_dir <- "terra_class/terra_class_2018_tiles/"
# Copy slide by bounding boxes
cube_lst <- purrr::map(tiles_bdc, function(tile){
    roi <- sits_tiles_to_roi(tile, "BDC_MD_V2")
    part <- sits_cube_copy(
        cube = terra_class_2018,
        roi = roi,
        output_dir = file.path(base_dir, tiles_terra_class_dir)
    )
    old_name <- part$file_info[[1]]$path
    new_name <- file.path(base_dir, tiles_terra_class_dir, paste0("/LANDSAT_OSI_",tile,"_2018-01-01_2018-12-31_class_30m.tif"))
    file.rename(from = old_name, to = new_name)
})
terra_class_2018_tiles <- sits_cube(
    source = "BDC",
    collection = "SENTINEL-2-16D",
    data_dir = file.path(base_dir, tiles_terra_class_dir),
    labels = labels_tc,
    bands = "class",
    multicores = 6,
    memsize = 12,
    version = "30m"
)

samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
# get class labels
labels_lucc <- sits_labels(samples_v13)
names(labels_lucc) <- c(1:length(labels_lucc))

# retrive classified map for the Cerrado
lucc_map_dir <- "cerrado_lucc_2018/"
cerrado_class_v14 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = file.path(base_dir, lucc_map_dir),
    labels = labels_lucc,
    bands = "class",
    version = "v14a",
    multicores = 8,
    memsize = 16
)
tiles_lucc_dir <- "cerrado_lucc_2018/cerrado_lucc_2018_tiles/"
# Copy slide by bounding boxes
cube_lst <- slider::slide(tiles_bdc, function(tile){
    roi <- sits_tiles_to_roi(tile, "BDC_MD_V2")
    part <- sits_cube_copy(
        cube = cerrado_class_v14,
        roi = roi,
        output_dir = file.path(base_dir, tiles_lucc_dir)
    )
    old_name <- part$file_info[[1]]$path
    new_name <- file.path(base_dir, tiles_lucc_dir,paste0("LANDSAT_OLI_",tile,"_2017-01-01_2018-12-31_class_v14a.tif"))
    file.rename(from = old_name, to = new_name)
    part$file_info[[1]]$path <- new_name
    part$tile <- tile
    part
})


tiles_lucc_dir <- "cerrado_lucc_2018/cerrado_lucc_2018_tiles/"
cerrado_class_tiles_v14 <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = file.path(base_dir, tiles_lucc_dir),
    labels = labels_lucc,
    bands = "class",
    version = "v14a"
)
tiles_urban_dir <- "cerrado_lucc_2018/cerrado_lucc_2018_tiles_urban/"
cerrado_class_tiles_v14 <- sits_reclassify(
    cube = cerrado_class_tiles_v14,
    mask = terra_class_2018_tiles,
    rules = list(
        "Urban_Area" = mask %in% c("Urban_Area", "Other Built-up Areas"),
        "Water"      = mask == "Water Bodies"
    ),
    output_dir = file.path(base_dir, tiles_urban_dir)
)
