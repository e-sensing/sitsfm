## sitsfm Package

**Scripts for testing foundational models in SITS**

This package contains scripts for running foundational models using the `sits` package. For more details, please refer to the section on embeddings in the 
[on-line book about `sits`](https://e-sensing.github.io/sitsbook/).

## Content of the scripts 

The scripts can be found in the `analysis` directory. All data necessary 
to run them in on Hugging Face. The results of each step are also available
in Hugging Face. 

1. `generate_ssl_encoders.R`: reads a set of samples and produces 
foundational models for the MAE, LeJEPA, VICReg, and Barlow Twins encoders
using self-supervised learning.

2. `generate_embeddings_cube_2018.R`: takes a two year Landsat-8 data cube
covering the Cerrado biome in Brazil from `2017-01-01` to `2018-12-31`
and generates embeddings cubes using
the MAE, LeJEPA, VICReg, and Barlow Twins encoders produced in step 1. 

3. `generate_embeddings_cube_2024.R`: takes a two year Landsat-8 data cube
covering the Cerrado biome in Brazil from `2023-01-01` to `2024-12-31`
and generates embeddings cubes using
the MAE, LeJEPA, VICReg, and Barlow Twins encoders produced in step 1.

4. `create_validation_points.R`: uses the result of classifications
produced using time series algorithms on data cubes (no embeddings)
combining agricultural classes produced by analysis using Sentinel-2 images
with natural cover classes using Landsat-8 from the period 2018 to 2024.
The resulting validation points are an approximation to a validation data
set that is used to assess the accuracy of the classification of the
embeddings cube.

5. `classify_vicreg_cube.R`: example of classification of an embeddings cube
using a set of labelled training samples and validated with the data set
produced in step 4. These data sets are independent. 

6. `accuracy_alpha_earth_2018.R`: use the validation points produced in 
step 4 to measure the accuracy of the classification of the Alpha Earth
embeddings for year 2018. This classification has been done using the
same set of labelled samples used in step 5. 

