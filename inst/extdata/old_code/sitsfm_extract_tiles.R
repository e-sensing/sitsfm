#' @title  Extract tiles from full cerrado classification
#' @name sitsfm_extract_tiles
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#' @description
#'
#' @param  source               Data source
#' @param  collection           Data collection
#' @param  satellite            Satellite
#' @param  sensor               Sensor
#' @param  base_dir             Base directory for files
#' @param  lucc_map_dir         Directory for LUCC map files (full mosaic)
#' @param  tiles_dir            Directory where to put the tiles
#' @param  tiles_bdc            Tiles to be extracted
#' @param  start_date           Start date
#' @param  end_date             End date for classification
#' @param  version              Version of the classification cube
#' @param  labels               Labels used in the classification
#'
#'
#' @return A summary of the sits tibble.
#'
#' @export
#'
sitsfm_extract_tiles <- function(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        satellite = "LANDSAT",
        sensor = "OLI",
        base_dir,
        lucc_map_dir,
        tiles_dir,
        tiles_bdc,
        start_date,
        end_date,
        version,
        labels){


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
            output_dir = file.path(base_dir, tiles_dir)
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
    dplyr::bind_rows(cube_lst)
}
