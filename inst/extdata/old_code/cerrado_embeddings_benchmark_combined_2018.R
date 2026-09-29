# get samples

# get class labels for TerraClass
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
terra_class_tiles <- sits_cube(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    data_dir = "/Volumes/KINGSTON/sitsfm/terra_class/terra_class_2024_tiles/",
    bands = "class",
    labels = labels_tc,
    version = "10m"
)
samples_per_class_natural <- c(
    "Cerradao" = 2000,
    "Cerrado" = 2000,
    "Mangrove" = 500,
    "Nat_NonVeg" = 500,
    "Open_Cerrado" = 2000,
    "Water" = 500
)

samples_per_class_land_use <- c(
    "Annual_Crop_1_Cycle" = 1500,
    "Annual_Crop_2_Cycles" = 1500,
    "Pasture" = 2000,
    "Perennial_Crop" = 1500,
    "Silviculture" = 1500,
    "Sugarcane" = 1500
)
# get validation data for natural land covers
samples_bench_natural <- sits_stratified_sampling(
    cube = cerrado_class_v14_tiles,
    samples_per_class = samples_per_class_natural,
    overhead = 1.0,
    multicores = 8,
    memsize = 32
)
validation_data_natural <- sits_sf_to_tibble(
    samples_bench_natural,
    start_date = "2023-01-01",
    end_date = "2024-12-31"
)


# remove stable classes
validation_data_natural <- validation_data_natural |>
    dplyr::filter(!(label %in% c("Mangrove", "Nat_NonVeg", "Water")))

# get validation data for land use classes
samples_bench_land_use <- sits_stratified_sampling(
    cube = terra_class_tiles,
    samples_per_class = samples_per_class_land_use,
    overhead = 1.0,
    multicores = 8,
    memsize = 32
)
validation_data_land_use <- sits_sf_to_tibble(
    samples_bench_land_use,
    start_date = "2023-01-01",
    end_date = "2024-12-31"
)

validation_data_land_use <- validation_data_land_use |>
    dplyr::mutate(label = dplyr::case_when(
        label %in% c("Annual_Crop_1_Cycle", "Annual_Crop_2_Cycles") ~ "Annual_Crop",
        .default = label
    ))

validation_data <- dplyr::bind_rows(validation_data_land_use,
                                    validation_data_natural)
sits_view(validation_data)
# get banchmarks
algorithms <- c("mae", "lejepa", "vicreg", "btwins", "supcon")

results <- purrr::map(algorithms, function(algo){
    data_dir <- paste0("/Volumes/KINGSTON/sitsfm/cerrado_emb_",algo,
                       "_tcnn_2024_class")
    print(data_dir)
    cube_class <- sits_cube(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        data_dir = data_dir,
        labels = labels,
        bands = "class",
        version = "v13"
    )
    # accuracy mae
    acc <- sits_accuracy(
        data = cube_class,
        validation = validation_data,
        method = "pixel"
    )
    acc$name <- toupper(algo)
    acc
})
# save to xlsx file
sits_to_xlsx(
        results,
        file = "~/sitsfm/inst/extdata/cerrado_models/benchmark_combined.xlsx")
)
