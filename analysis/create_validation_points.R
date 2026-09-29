#
# Create validation data for 2018 evaluation
#

#
# Recover consensus data for natural classes from Hugging Face
#
natural_dir <- "./data/cubes/cerrado_natural"
dir.create(natural_dir, recursive = TRUE)
#
# Consensus cube with natural classes only
#
cerrado_natural_cube <- sits_from_hf(
    repo = "e-sensing/cerrado_lucc_natural_tiles",
    output_dir = natural_dir
)
#
# retrieve TerraClass 2018 (no boundaries) from Hugging Face
#
terra_class_dir <- "./data/cubes/terra_class_2018"
dir.create(terra_class_dir, recursive = TRUE)
#
terra_class_2018 <- sits_from_hf(
    repo = "e-sensing/cerrado_terra_class_2018_boundary_tiles",
    type = "dataset",
    output_dir = terra_class_dir
)
#
# retrieve Pasture 2018 (no boundaries) from Hugging Face
#
# create directory
pasture_dir <- "./data/cubes/pasture_2018"
dir.create(pasture_dir, recursive = TRUE)
#
# retrieve cube
#
pasture_cube <- sits_from_hf(
    repo = "e-sensing/cerrado_pasture_tiles_2018",
    type = "dataset",
    output_dir = "./data/cubes/pasture_2018"
)
#
# Reclassify TerraClass 2018 to match pasture data
#
tc_pasture_dir <- "./data/cubes/terra_class_2018_pasture"
dir.create(tc_pasture_dir, recursive = TRUE)
#
# Reclassify
#
terra_class_2018_tiles_pasture <- sits_reclassify(
    cube = terra_class_2018,
    mask = pasture_cube,
    rules = list(
        "Pasture"   = mask %in% c("Pasture") &
            cube %in% c("Secondary Vegetation", "Not Observed",
                        "Deforestation", "Other Built-up Areas",
                        "Other Uses", "Mining", "Urban_Area"
            ),
        "Not Observed" = !mask %in% c("Pasture") & cube %in% c("Pasture")
    ),
    output_dir = tc_pasture_dir,
    multicores = 6,
    memsize = 12
)
#
#  Join TerraClass/Pasture with Natural classes
#
tc_2018_pasture_natural_dir <- "./data/cubes/tc_2018_pasture_natural"
dir.create(tc_2018_pasture_natural_dir, recursive = TRUE)
#
#
#
tc_2018_pasture_natural <- sits_reclassify(
    cube = terra_class_2018_tiles_pasture,
    mask = cerrado_natural_cube,
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
    output_dir = tc_2018_pasture_natural_dir,
    multicores = 6,
    memsize = 12
)
# sampling desing
cerrado_sampling_design <- sits_sampling_design(
    cube = tc_2018_pasture_natural,
    expected_ua = c(
        "Cerradao" = 0.7,
        "Cerrado" = 0.7,
        "Open_Cerrado" = 0.7,
        "Annual_Crop_1_Cycle" = 0.7,
        "Annual_Crop_2_Cycles" = 0.7,
        "Pasture" = 0.7,
        "Perennial_Crop" = 0.6,
        "Silviculture" = 0.7,
        "Sugarcane" = 0.7
    ),
    alloc_options = 2000,
    std_err = 0.003,
    rare_class_prop = 0.1
)
# print sampling design
print(cerrado_sampling_design)

# select samples per class using alloc = 2000
samples_per_class <- c(
    "Cerradao" = 2000,
    "Cerrado" = 6000,
    "Open_Cerrado" = 3000,
    "Annual_Crop_1_Cycle" = 2000,
    "Annual_Crop_2_Cycles" = 2000,
    "Pasture" = 3000,
    "Perennial_Crop" = 2000,
    "Silviculture" = 2000,
    "Sugarcane" = 2000
)
# get validation data for land use classes
samples_bench <- sits_stratified_sampling(
    cube = tc_2018_pasture_natural,
    samples_per_class = samples_per_class,
    overhead = 1.0,
    multicores = 8,
    memsize = 32
)
# convert to tibble
validation_data <- sits_sf_to_tibble(
    samples_bench,
    start_date = "2018-01-01",
    end_date = "2018-12-31"
)
# Join Annual Crop Classes
validation_data <- validation_data |>
    dplyr::mutate(label = dplyr::case_when(
        label %in% c("Annual_Crop_1_Cycle", "Annual_Crop_2_Cycles") ~ "Annual_Crop",
        .default = label
    ))
# visualise validation data
sits_view(validation_data)

# save validation data
validation_dir <- "./data/validation"
dir.create(validation_dir, recursive = TRUE)
sits_to_parquet(validation_data, "./data/validation/validation_data_2018.parquet")
