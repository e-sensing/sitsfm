# Example of embeddings cube classification using VICReg encoder
#
library(sits)
#
#  Create directory for Alpha Earth 2018
#
alpha_earth_dir <- "./data/results/alpha_earth/alpha_earth_2018"
dir.create(alpha_earth_dir, recursive = TRUE)
#
#  Retrieve classified Alpha Earth cube
#
alpha_earth_2018 <- sits_from_hf(
    repo = "e-sensing/alpha_earth_2018",
    type = "dataset",
    output_dir = alpha_earth_dir
)
#
#  Recover validation data
#
validation_data <- sits_from_hf(
    repo = "e-sensing/samples_cerrado",
    file = "validation_data_2018.parquet",
    type = "dataset"
)
#
#  Measure accuracy
#
acc <- sits_accuracy(
    data = alpha_earth_2018,
    validation = validation_data,
    method = "pixel"
)
acc$name <- "AlphaEarth_2018_01"
#
# include accuracy in results list
#
results <- list()
results[[length(results) + 1 ]] <- acc
#
#  Save to xlsx file
#
sits_to_xlsx(
    results,
    file = "./data/benchmarks_2018/acc_alpha_earth_100.xlsx"
)

