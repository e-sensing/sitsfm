#' @title  Obtain benchmarks for the cerrado LUCC maps
#' @name sitsfm_benchmark
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#' @description
#'
#' @param  validation_data      Tibble with lat/long position of validation pixels.
#' @param  emb_algorithms       Embedding algorithms to be evaluated
#' @param  year                 Reference year for classifications
#' @param  scenario_emb         Scenario used for assessment
#' @param  base_dir             Base directory for files
#' @param  emb_dir              Base part of directory for embeddings
#' @param  lucc_dir             Directory for Cerrado LUCC files
#' @param  version_emb          Version of the embeddings classification
#' @param  version_tcnn         Version of the standard TempCNN classification
#' @param  use_alpha_earth      Include ALPHA EARTH data in the comparison
#' @param  alpha_earth_dir      Directory where Alpha Earth is located
#' @param  version_alpha        ALPHA EARTH version of the classification
#' @param  labels               Labels used in the classification
#'
#'
#' @return A summary of the sits tibble.
#'

sitsfm_benchmark <- function(
        validation_data,
        emb_algorithms,
        year,
        base_dir,
        emb_dir,
        scenario_emb,
        version_emb,
        lucc_dir,
        version_lucc,
        use_alpha_earth,
        alpha_earth_dir,
        version_alpha,
        labels){


    # results from embeddings
    results <- purrr::map(emb_algorithms, function(algo){
        emb_class_dir <- paste0(
            scenario_emb,"/",
            emb_dir, "_", algo, "_tcnn_", year, "/",
            emb_dir, "_", algo, "_tcnn_", year, "_class")
        data_dir <- file.path(base_dir, emb_class_dir)
        print(data_dir)
        cube_class <- sits::sits_cube(
            source = "BDC",
            collection = "LANDSAT-OLI-16D",
            data_dir = data_dir,
            labels = labels,
            bands = "class",
            version = version_emb
        )
        # accuracy
        acc <- sits::sits_accuracy(
            data = cube_class,
            validation = validation_data,
            method = "pixel"
        )
        acc$name <- toupper(algo)
        acc
    })

    cerrado_cube_tcnn_2018 <- sits::sits_cube(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        data_dir = file.path(base_dir, lucc_dir),
        labels = labels,
        bands = "class",
        version = version_tcnn
    )
    acc_lucc <- sits::sits_accuracy(
        data = cerrado_cube_tcnn_2018,
        validation = validation_data,
        method = "pixel"
    )
    acc_lucc$name <- "TempCNN"

    results[[length(results) + 1 ]] <- acc_lucc
    results
}
