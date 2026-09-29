
#' @title  Classify embeddings
#' @name sitsfm_embeddings_classification
#' @author Gilberto Camara, \email{gilberto.camara@@inpe.br}
#' @description
#'
#' @param  source               Data source
#' @param  collection           Data collection
#' @param  samples              Samples for classification
#' @param  encoder              Encoder for classification
#' @param  emb_dir              Directory for embeddings
#' @param  dest_dir             Destination directory for classification
#' @param  version              Version of the classification cube
#' @param  multicores           Multicores to be used
#' @param  memsize              Memory size in RAM
#' @param  gpu_memory           GPU memory
#' @param  train_batch_size     Batch size for traning
#' @param  class_batch_size     Batch size for classification
#'
#'
#' @return A summary of the sits tibble.
#'
#' @export
#'
sitsfm_embbedings_classification <- function(
        source = "BDC",
        collection = "LANDSAT-OLI-16D",
        samples,
        encoder,
        emb_dir,
        dest_dir,
        version = "mlp",
        multicores = 6,
        memsize = 12,
        gpu_memory = 12,
        train_batch_size = 512,
        class_batch_size = 2^16
){

    # encode samples
    samples_emb <- sits::sits_encode(
        data = samples,
        encoder = encoder,
        multicores = multicores,
        gpu_memory = gpu_memory,
        batch_size = train_batch_size
    )

    # recover sits_regular cube
    cube_emb <- sits::sits_cube(
        source = source,
        collection = collection,
        data_dir = emb_dir,
        multicores = 6,
        memsize = 12
    )

    #
    # MLP classifier
    #
    mlp_model <- sits::sits_train(
        samples_emb,
        ml_method = sits::sits_mlp(
            min_delta = 0.005,
            epochs = 150,
            batch_size = 128,
            verbose = TRUE
        )
    )
    # Probability cube
    cube_probs <- sits::sits_classify(
        data = cube_emb,
        ml_model = mlp_model,
        memsize = memsize,
        multicores = multicores,
        gpu_memory = gpu_memory,
        batch_size = class_batch_size,
        output_dir = dest_dir,
        version = version
    )
    # Smoothed cube
    cube_smooth <- sits::sits_smooth(
        cube = cube_probs,
        memsize = 30,
        multicores = 10,
        output_dir = dest_dir,
        version = version
    )
    # Classification map
    cube_class <- sits::sits_label_classification(
        cube_smooth,
        memsize = 32,
        multicores = 8,
        output_dir = dest_dir,
        version = version
    )
}
