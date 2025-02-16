**Code repository for:**

Preprint to come

For any questions regarding the use of this repository, please get in touch at alexa.mousley@mrc-cbu.cam.ac.uk

**Required Software**
1) MATLAB 2020B (installation: https://uk.mathworks.com/help/install/install-products.html)
2) RStudio 4.1.2 (installation: https://rstudio.com/products/rstudio/download/)
3) Python 3.7.3 via Jupyter Noteboook (installation: https://docs.jupyter.org/en/latest/install/notebook-classic.html)

**Required Toolbox**
1) Brain Connectivity Toolbox (https://sites.google.com/site/bctnet/home?authuser=0)
Rubinov, M., & Sporns, O. (2010). Complex network measures of brain connectivity: uses and interpretations. Neuroimage, 52(3), 1059-1069.

**Script outline:**

set_paths.m and set_paths.py - Add paths paths to the data and toolbox (it will be called in 

Scripts are ordered based on analysis proceedures:
- A_network_thresholding.m                 (threshold networks for density-controlled and variable-density analysis)
- B_harmonize_networks_and_select_sample.m (harmonize networks and select analysis sample)
- C_small_worldness.m                      (function for calculating sigma using null models)
- D_calculate_organization_measures.m      (calculate graph theory measures on networks)
- E_generalized_additive_models.R          (models using age to predict individual graph theory measures)
- F_define_turning_points.ipynb            (create UMAPs and find turning points)
- G_run_pca.m                              (run PCA on the whole sample)
- H_run_lasso.m                            (run LASSO regressions for each epoch)
- I_correlations_and_lasso_analysis.ipynb  (run correlations per epoch and plot with LASSO coefficients)
- J_PCA_analysis.ipynb                     (assess PCA score differences between epochs)
- K_dynamic_time_warping.ipynb             (DTW analysis on PCA series for each epoch)

UMAP_functions.ipynb - defined functions for creating multiple UMAPs and defining turning points called script F.

**Data Dictionary**

Demographic data
- Age: Years
- Sex: Male = 0, female = 1
- Atlas: neonatal = 1, 1-year-old = 2, 2-year-old = 3, adult = 4
- Group: neurotypical = 1, neurodiverse = 2
- Dataset: dHCP = 1, BCP = 2, CALM = 3, RED = 4, ACE = 5, HCPd = 6, HCPya = 7, camCAN = 8, HCPa = 9

Data Workflow

Connectomes
- all_data (n = 4,216): Contains all scans (longitudinal/repeat scans, neurodiverse sample and outliers)
- thesholded_data (n = 4,202): After removing outliers, this is the thresholded data 
- harmonized_data (n = 3,802): This data was harmonized, then longitudinal/repeat scans and neurodiverse participants were removed. This is the sample used in the analysis.

Indexes
- crosssectional_index: 1 indicates scans that should be kept for crossestional analysis (e.g., 0 indicates a longitidunial or repeat scan)
- analysis_index: Inditifies the index for all participants that are kept in for the main analysis (e.g., the crosssectional, neurotypical sample)

Organizational Measures
- density-controlled_organizational_measures (3,802 x 12): Double containing all graph theory metrics calculated from density-controlled networks
- variable-controlled_organizational_measures (3,802 x 12): Double containing all graph theory metrics calculated from variable density networks
- graph_theory_measure_labels (1x12): String indicating the label of the graph theory metrics for the organizational_measures doubles

UMAPs and Turning Points
- umap_input_data: Struct containing age-predicted organizational measures used in the UMAP 
- UMAP_results: Dictionary containing all UMAPs 
- turning_point_results: Dictionary containing lines of best fit, all turning points identified, and major turning points 

Additional Data
- demographics.csv: Contians all demographic data used in the analysis
- target_density (91x1): The target densities for each age group (0-90) used in the variable density thresholding procedure 
- pca_*: various PCA outputs (e.g., scores, loadings, etc)
- lass_coefs: the coefficients from the LASSO regressions per epoch



