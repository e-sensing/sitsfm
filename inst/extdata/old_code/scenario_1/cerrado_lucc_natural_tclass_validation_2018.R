#
# Prepare validation data
#
# Base directory for data access
# Replace as appropriate for reproducibility
#
base_dir <- "/Volumes/KINGSTON/sitsfm/"

# BDC tiles for classification evaluation
tiles_bdc <- c(
    "017004", "015005", "015006",
    "015007", "014008", "015009",
    "009010", "013010", "013012",
    "014012", "011013", "013014"
)

# Labels for consensus natural classes

labels_natural <- c(
    "0" = "Anthropic",
    "2" = "Cerradao",
    "3" = "Cerrado",
    "4" = "Mangrove",
    "5" = "Nat_NonVeg",
    "6" = "Open_Cerrado"
)
# directory where consensus map of natural classes is stored
natural_dir <- "cerrado_lucc_natural"

# consensus cube with natural classes only
cerrado_natural_cube <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = file.path(base_dir, natural_dir),
    labels = labels_natural,
    bands = "class",
    version = "v14a",
    multicores = 6,
    memsize = 12
)

# extract tiles from consensus natural map
#
tiles_natural_dir <- "/cerrado_lucc_natural/cerrado_lucc_natural_tiles"
# Copy slide by bounding boxes
cube_lst <- purrr::map(tiles_bdc, function(tile){
    bb <- sits_tiles_to_roi(tile, "BDC_MD_V2")
    part <- sits_cube_copy(
        cube = cerrado_natural_cube,
        roi = bb,
        crs = "EPSG:4326",
        output_dir = file.path(base_dir, tiles_natural_dir)
    )
    old_name <- part$file_info[[1]]$path
    new_name <- paste0(file.path(base_dir, tiles_natural_dir), paste0("/LANDSAT_OLI_",tile,"_2017-01-01_2024-12-31_class_natural.tif"))
    file.rename(from = old_name, to = new_name)
    part$file_info[[1]]$path <- new_name
    part$tile <- tile
    part
})
# consensus cube for natural classes split by tiles
cerrado_natural_cube_tiles <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = file.path(base_dir, tiles_natural_dir),
    labels = labels_natural,
    bands = "class",
    version = "natural",
    multicores = 6,
    memsize = 12
)
# get samples for TerraClass
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
terra_class_dir <- "terra_class/terra_class_2018_boundary"
# retrieve terra class 2018
#
terra_class_2018 <- sits_cube(
    source = "BDC",
    collection = "SENTINEL-2-16D",
    data_dir = file.path(base_dir, terra_class_dir),
    labels = labels_tc,
    bands = "class",
    version = "boundary",
    multicores = 6,
    memsize = 12
)
tiles_terra_class_dir <- "terra_class/terra_class_2018_boundary_tiles/"
# Copy slide by bounding boxes
cube_lst <- purrr::map(tiles_bdc, function(tile){
    roi <- sits_tiles_to_roi(tile, "BDC_MD_V2")
    part <- sits_cube_copy(
        cube = terra_class_2018,
        roi = roi,
        output_dir = file.path(base_dir, tiles_terra_class_dir)
    )
    old_name <- part$file_info[[1]]$path
    new_name <- file.path(base_dir, tiles_terra_class_dir, paste0("/SENTINEL-2_MSI_",tile,"_2018-01-01_2018-12-31_class_30m.tif"))
    file.rename(from = old_name, to = new_name)
})
# TerraClass 2018 map split by tiles
terra_class_2018_tiles <- sits_cube(
    source = "BDC",
    collection = "SENTINEL-2-16D",
    data_dir  = file.path(base_dir, tiles_terra_class_dir),
    labels = labels_tc,
    bands = "class",
    version = "30m",
    multicores = 6,
    memsize = 12
)

# Include pasture map
pasture_map <- terra::vect(file.path(base_dir,"/pasture/", "brasil_pasture_col9_s100_year=2018.gpkg"))
pasture_tiles_dir <- "/pasture/pasture_tiles_2018"
spat_vec_lst <- purrr::map(tiles_bdc, function(tile){
    terra_rast <- sits_as_terra(terra_class_2024_tiles_natural, tile = tile)
    ext <- terra::ext(terra_rast)
    pasture_map_ext <- terra::project(ext, from = terra::crs(terra_rast),
                                      to = terra::crs(pasture_map)
    )
    crop_tile <- terra::crop(pasture_map, pasture_map_ext)
    crop_tile_proj <- terra::project(crop_tile, terra::crs(terra_rast))
    crop_tile_proj$label <- 11
    crop_rast <- terra::rasterize(
        x = crop_tile_proj,
        y = terra_rast,
        field = "label",
        filename = file.path(
            base_dir,
            pasture_tiles_dir,
            paste0("LANDSAT_OLI_",tile,"_2018-01-01_2018-12-31_class_pasture.tif")),
        wopt = list(
            datatype = "INT1U",
            gdal = c("COMPRESS=LZW", "PREDICTOR=2",
                     "TILED=YES", "BLOCKXSIZE=512",
                     "BLOCKYSIZE=512")
        )
    )
})

# Reclassify
#
labels_pasture <- c(
    "0" = "Non_Pasture",
    "11" = "Pasture"
)
pasture_cube <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir  = file.path(base_dir, pasture_tiles_dir),
    labels = labels_pasture,
    bands = "class",
    version = "pasture",
    multicores = 6,
    memsize = 12
)
tc_tiles_boundary_pasture_dir <- "terra_class/terra_class_2018_boundary_tiles_pasture"
terra_class_2018_tiles_pasture <- sits_reclassify(
    cube = terra_class_2018_tiles,
    mask = pasture_cube,
    rules = list(
        "Pasture"   = mask %in% c("Pasture") &
            cube %in% c("Secondary Vegetation", "Not Observed",
                        "Deforestation", "Other Built-up Areas",
                        "Other Uses", "Mining", "Urban_Area"
                        ),
        "Not Observed" = !mask %in% c("Pasture") & cube %in% c("Pasture")
    ),
    output_dir = file.path(base_dir, tc_tiles_boundary_pasture_dir),
    multicores = 6,
    memsize = 12
)

tc_tiles_boundary_natural_dir <- "terra_class/terra_class_2018_boundary_tiles_natural"
terra_class_2018_tiles_natural <- sits_reclassify(
    cube = terra_class_2018_tiles_pasture,
    mask = cerrado_natural_cube_tiles,
    rules = list(
        "Cerradao"   = mask %in% c("Cerradao") &
            cube %in% c("Natural Vegetation", "Secondary Vegetation"),
        "Cerrado"   = mask %in% c("Cerrado") &
            cube %in% c("Natural Vegetation", "Secondary Vegetation"),
        "Open_Cerrado"   = mask %in% c("Open_Cerrado") &
            cube %in% c("Natural Vegetation", "Secondary Vegetation"),
        "Nat_NonVeg"   = mask %in% c("Nat_NonVeg") &
            cube %in% c("Natural Vegetation", "Secondary Vegetation"),
        "Mangrove"   = mask %in% c("Mangrove") &
            cube %in% c("Natural Vegetation", "Secondary Vegetation")
    ),
    output_dir = file.path(base_dir, tc_tiles_boundary_natural_dir),
    multicores = 6,
    memsize = 12
)
samples_per_class <- c(
    "Cerradao" = 2000,
    "Cerrado" = 3000,
    "Open_Cerrado" = 3000,
    "Annual_Crop_1_Cycle" = 1500,
    "Annual_Crop_2_Cycles" = 1500,
    "Pasture" = 3000,
    "Perennial_Crop" = 1500,
    "Silviculture" = 1500,
    "Sugarcane" = 1500
)

# get validation data for land use classes
samples_bench <- sits_stratified_sampling(
    cube = terra_class_2018_tiles_natural,
    samples_per_class = samples_per_class,
    overhead = 1.0,
    multicores = 8,
    memsize = 32
)
validation_data <- sits_sf_to_tibble(
    samples_bench,
    start_date = "2017-01-01",
    end_date = "2018-12-31"
)

validation_data <- validation_data |>
    dplyr::mutate(label = dplyr::case_when(
        label %in% c("Annual_Crop_1_Cycle", "Annual_Crop_2_Cycles") ~ "Annual_Crop",
        .default = label
    ))
sits_view(validation_data)

saveRDS(validation_data, "~/sitsfm/inst/extdata/cerrado_samples/validation_data_2018.rds")


