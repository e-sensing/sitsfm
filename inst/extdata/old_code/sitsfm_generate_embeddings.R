# Generate embeddings
#
#' @title  Generate embeddins
#' @name sitsfm_generate_embeddings
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#' @description
#'
#' @param  source               Data source
#' @param  collection           Data collection
#' @param  samples              Samples for classification
#' @param  encoder              Encoder for classification
#' @param  data_dir             Base directory for files
#' @param  tiles                Tiles to be extracted
#' @param  emb_dir              Directory for embeddings
#' @param  version              Version of the classification cube
#' @param  multicores           Multicores to be used
#' @param  memsize              Memory size in RAM
#' @param  gpu_memory           GPU memory
#' @param  train_batch_size     Batch size for traning
#' @param  class_batch_size     Batch size for classification
#'
#'
#
sitsfm_generate_embeddings <- function(
    source = "BDC",
    collection = "LANDSAT-OLI-16D",
    encoder,
    data_dir,
    tiles = NULL,
    emb_dir,
    memsize,
    multicores,
    gpu_memory,
    batch_size
){
    cube_input <- sits::sits_cube(
        source = source,
        collection = collection,
        tiles = tiles,
        data_dir = data_dir,
        multicores = 6
    )

    cube_emb <- sits::sits_encode(
        data = cube_input,
        encoder = encoder,
        memsize = 12,
        multicores = 6,
        gpu_memory = 12,
        batch_size = 4096,
        output_dir = emb_dir
    )
}
