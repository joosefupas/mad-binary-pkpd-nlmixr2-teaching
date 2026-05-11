# Multiple Ascending Dose PK/PD Binary Response Hands-on Session

This repository contains teaching material for a hands-on pharmacometrics session using a simulated multiple ascending dose PK/PD dataset.

The session focuses on exploratory analysis, binary pharmacodynamic response summaries, dose-response visualisation, longitudinal responder-rate analysis, and categorical modeling using `nlmixr2`.

## Repository contents

The repository is composed of the following main files:

```text
.
├── README.md
├── mad_binary_pd_teaching_session.qmd
└── vpc_from_nlmixr2_fit.R
```

## File descriptions

### `mad_binary_pd_teaching_session.qmd`

Main Quarto teaching script.

This file contains the complete hands-on workflow, including:

- Loading and preparing the multiple ascending dose dataset.
- Inspecting the structure of the data.
- Filtering binary pharmacodynamic response data.
- Creating responder-rate summaries.
- Computing exact binomial confidence intervals.
- Producing exploratory plots.
- Evaluating dose-response relationships.
- Exploring exposure-response relationships.
- Creating longitudinal responder-rate visualisations.
- Summarising study design characteristics.
- Preparing data for categorical modeling in `nlmixr2`.
- Loading a pre-fitted `nlmixr2` model object.
- Generating a categorical visual predictive check.

The file is intended to be rendered as an HTML teaching document.

### `vpc_from_nlmixr2_fit.R`

Helper R script containing utility functions for generating a categorical VPC from an `nlmixr2` fit.

The main exported function is:

```r
plot_categorical_vpc_nlmixr2()
```

This function:

- Extracts model expressions from an `nlmixr2` fit.
- Rewrites categorical string comparisons into numeric indicator variables.
- Prepares model data for simulation.
- Extracts fixed effects and random-effect covariance information.
- Simulates binary outcomes from the fitted model.
- Computes simulated prediction intervals.
- Overlays empirical response probabilities with model-based simulated intervals.

This script is sourced inside the Quarto document:

```r
source("vpc_from_nlmixr2_fit.R")
```

## Dataset

The teaching session uses the `mad` dataset from the `xgxr` package.

This is a model-generated multiple ascending dose dataset designed to mimic an orally administered small molecule with multiple PK and PD endpoints.

The analysis focuses primarily on the binary pharmacodynamic endpoint.

## Endpoint structure

The dataset uses the `CMT` column to identify different event or observation types.

| `CMT` | Description |
|---|---|
| 1 | Dosing event |
| 2 | PK concentration |
| 3 | Continuous response data |
| 4 | Count response data |
| 5 | Ordinal response data |
| 6 | Binary response data |

The main endpoint used in this teaching session is:

```r
PD_CMT <- 6
```

## Learning objectives

By the end of the session, students should be able to:

- Understand the structure of a simulated multiple ascending dose PK/PD dataset.
- Identify dosing records, PK records, and PD response records.
- Prepare binary pharmacodynamic response data for analysis.
- Summarise binary responder rates using exact binomial confidence intervals.
- Visualise responder rates over time.
- Explore dose-response relationships.
- Explore exposure-response relationships.
- Create longitudinal response plots with dosing event overlays.
- Prepare data for categorical modeling in `nlmixr2`.
- Interpret a simple binary response model.
- Generate and interpret a categorical visual predictive check.

## Required R packages

The Quarto document uses the following R packages:

```r
library(gridExtra)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(xgxr)
library(RColorBrewer)
library(binom)
library(nlmixr2)
library(rxode2)
library(MASS)
```

If needed, install the packages before running the session:

```r
install.packages(c(
  "gridExtra",
  "ggplot2",
  "dplyr",
  "tidyr",
  "scales",
  "RColorBrewer",
  "binom",
  "MASS"
))
```

The packages `xgxr`, `nlmixr2`, and `rxode2` may require additional installation steps depending on the R environment.

## Required software

To run the full teaching session, students should have:

- R installed.
- RStudio or another R-compatible IDE.
- Quarto installed.
- The required R packages installed.
- The repository files placed in the same working directory.

## How to render the teaching document

From RStudio:

1. Open `mad_binary_pd_teaching_session.qmd`.
2. Click **Render**.
3. The HTML teaching document will be generated.

From the terminal:

```bash
quarto render mad_binary_pd_teaching_session.qmd
```

## Recommended workflow for students

Students should work through the Quarto document section by section:

1. Load packages.
2. Define constants.
3. Load the dataset.
4. Inspect the dataset.
5. Prepare binary PD data.
6. Create helper functions.
7. Generate exploratory plots.
8. Examine dose-response relationships.
9. Explore exposure-response relationships.
10. Summarise longitudinal responder rates.
11. Inspect study design summaries.
12. Prepare modeling data.
13. Inspect the `nlmixr2` model.
14. Load the fitted model object.
15. Generate the categorical VPC.
16. Discuss model interpretation and limitations.

## Main analysis steps

### 1. Data preparation

The Quarto document creates additional analysis variables:

```r
PROFDAY
DAY_label
TRTACT_low2high
TRTACT_high2low
```

These variables are used for plotting, grouping, and model preparation.

### 2. Binary PD filtering

The binary response endpoint is selected using:

```r
pd_data <- data |>
  filter(CMT == PD_CMT)
```

where:

```r
PD_CMT <- 6
```

### 3. Binomial responder summaries

Responder rates are summarised using exact binomial confidence intervals.

The key helper function is:

```r
summarise_binom()
```

This function returns:

- Number of observations.
- Number of responders.
- Response proportion.
- Lower confidence interval.
- Upper confidence interval.

### 4. Exploratory plots

The session includes plots for:

- Binary responder rate over time.
- Dose-response at Day 6.
- Dose-response by selected profile days.
- Exposure by binary response.
- Longitudinal responder rate by dose.
- Overall active-treatment responder rate.

### 5. Study design summaries

The Quarto document creates a treatment-level summary table containing:

- Number of patients.
- Total number of records.
- Number of PD records.
- Number of dosing records.
- Number of nominal sampling times.
- List of nominal sampling times.

### 6. nlmixr2 model

The categorical model describes the probability of binary response using a logit relationship.

The general form is:

```text
logit(p) = baseline effect + treatment effect + weight effect + sex effect + time effect
```

The binary outcome is modeled as:

```text
Y ~ Binomial(n = 1, p)
```

The model includes:

- Treatment effects.
- Baseline body weight effect.
- Sex effect.
- Time effect.
- Between-subject random effects.

### 7. Categorical VPC

The categorical VPC compares:

- Empirical observed responder probability.
- Predicted median responder probability.
- Simulated prediction interval.

The helper function used is:

```r
plot_categorical_vpc_nlmixr2()
```


## Reproducibility

The analysis uses a fixed random seed:

```r
set.seed(12345)
```

The same seed is also used in the categorical VPC simulation:

```r
seed = 12345
```

This helps make the output reproducible across runs, although small differences may still occur across package versions or operating systems.



## Suggested citation or acknowledgement

This teaching material uses the `mad` example dataset from the `xgxr` R package and demonstrates modeling workflows using `nlmixr2` and `rxode2`.

## License

```text
MIT License
```
