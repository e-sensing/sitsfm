## sitsfm Package
Scripts for testing foundational models in SITS

## Run in the following order

1. `generate_foundation_models.R`: reads a set of samples and produces 
foundational models for the MAE, LeJEPA, VICReg, Barlow Twins, and SUPCON encoders.

2. `cerrado_lucc_2024_tiles.R`: extract a set of tiles from 2024 LUCC 
classification. 

3. `cerrado_emb_class_mae_2024.R`, `cerrado_emb_class_lejepa_2024.R`,
`cerrado_emb_class_vicreg_2024.R`, `cerrado_emb_class_btwins_2024.R`,
`cerrado_emb_class_supcon_2024.R`: produce embeddings for 2024 LUCC tiles and
classify them using samples_v13.

4. `cerrado_lucc_2024_urban.R`: reclassifies 2024 LUCC tiles based 
on TerraClass 2024 information on urban areas and water bodies.

5. `cerrado_embeddings_benchmark_urban.R`: uses the 2024 LUCC tiles to 
produce a set of stratified samples, calculates accuracy assessment for
the classifications produced by each embeddings, and stores the results
as a XLSX file. 
