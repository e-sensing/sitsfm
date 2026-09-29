# Save tiles from the cerrado LUCC 2018 map


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
lucc_map_dir <- "cerrado_lucc_2018/"
version <- "v14a"
# produce a new data cube only for the selected tiles
tiles_dir <- "cerrado_lucc_2018/cerrado_lucc_2018_tiles/"
# start and end date
start_date <- "2017-01-01"
end_date   <- "2018-12-31"
# source, collection, satellite, sensor
source <- "BDC"
collection <- "LANDSAT-OLI-16D"
satellite <- "LANDSAT"
sensor <- "OLI"

# labels
# get samples
samples_v13 <- readRDS("~/sitsfm/inst/extdata/cerrado_samples/samples-cer-v13a.rds")
# get class labels
labels <- sits::sits_labels(samples_v13)
names(labels) <- c(1:length(labels))

# call function
#
cerrado_lucc_2018_tiles <- sitsfm_extract_tiles(
    source = source,
    collection = collection,
    satellite = satellite,
    sensor = sensor,
    base_dir = base_dir,
    lucc_map_dir = lucc_map_dir,
    tiles_dir = tiles_dir,
    tiles_bdc = tiles_bdc,
    start_date = start_date,
    end_date = end_date,
    version = version,
    labels = labels
)
