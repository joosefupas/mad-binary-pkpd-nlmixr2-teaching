# Multiple Ascending Dose PK/PD Binary Response Hands-on Session

This repository contains teaching material for a hands-on pharmacometrics session using a simulated multiple ascending dose PK/PD dataset.

The session focuses on exploratory analysis, binary pharmacodynamic response summaries, dose-response visualisation, longitudinal responder-rate analysis, and categorical modeling using `nlmixr2`.

The main modeling endpoint is a binary pharmacodynamic response, where each observation is either:

$$
Y = 1
$$

for a responder, or

\[
Y = 0
\]

for a non-responder.

A fitted categorical `nlmixr2` model is used to simulate binary response profiles and generate a categorical visual predictive check, or categorical VPC.

---

## Repository contents

The repository is composed of the following main files:

```text
.
├── README.md
├── mad_binary_pd_teaching_session.qmd
└── vpc_from_nlmixr2_fit.R
```

---

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

The main user-facing function is:

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

---

## Exact integration point for `vpc_from_nlmixr2_fit.R`

The helper file should be placed in the same directory as:

```text
mad_binary_pd_teaching_session.qmd
```

The source call should be added in the Quarto document after the package-loading chunk and before the first use of `plot_categorical_vpc_nlmixr2()`.

Recommended location in `mad_binary_pd_teaching_session.qmd`:

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

source("vpc_from_nlmixr2_fit.R")
```

The categorical VPC should be generated only after:

1. The binary PD analysis dataset has been prepared.
2. The `nlmixr2` fitted model object has been loaded.
3. The data columns required by the model are available in the dataset.

A typical call is:

```r
plot_categorical_vpc_nlmixr2(
  fit = fit,
  data = modeling_data,
  id_col = "ID",
  time_col = "TIME",
  dv_col = "DV",
  pred_var = "p1",
  nBins = 10,
  nSim = 200,
  ci = 0.95,
  seed = 12345,
  x_transform = function(x) x / 24,
  xlab = "Time (days)",
  ylab = "P(Y = 1)",
  title = "Categorical VPC"
)
```

The argument `fit` should be the fitted `nlmixr2` model object.

The argument `data` should be the analysis dataset used for model-based prediction and VPC simulation.

---

## Dataset

The teaching session uses the `mad` dataset from the `xgxr` package.

This is a model-generated multiple ascending dose dataset designed to mimic an orally administered small molecule with multiple PK and PD endpoints.

The analysis focuses primarily on the binary pharmacodynamic endpoint.

---

## Endpoint structure

The dataset uses the `CMT` column to identify different event or observation types.

| `CMT` | Description |
|---:|---|
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

Binary PD records are selected using:

```r
pd_data <- data |>
  filter(CMT == PD_CMT)
```

---

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

---

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

If needed, install the CRAN packages before running the session:

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

---

## Required software

To run the full teaching session, students should have:

- R installed.
- RStudio or another R-compatible IDE.
- Quarto installed.
- The required R packages installed.
- The repository files placed in the same working directory.

---

## How to render the teaching document

From RStudio:

1. Open `mad_binary_pd_teaching_session.qmd`.
2. Click **Render**.
3. The HTML teaching document will be generated.

From the terminal:

```bash
quarto render mad_binary_pd_teaching_session.qmd
```

---

## Recommended workflow for students

Students should work through the Quarto document section by section:

1. Load packages.
2. Source `vpc_from_nlmixr2_fit.R`.
3. Define constants.
4. Load the dataset.
5. Inspect the dataset.
6. Prepare binary PD data.
7. Create helper functions for summaries and plots.
8. Generate exploratory plots.
9. Examine dose-response relationships.
10. Explore exposure-response relationships.
11. Summarise longitudinal responder rates.
12. Inspect study design summaries.
13. Prepare modeling data.
14. Inspect the `nlmixr2` model.
15. Load the fitted model object.
16. Generate the categorical VPC.
17. Discuss model interpretation and limitations.

---

# Main analysis steps

## 1. Data preparation

The Quarto document creates additional analysis variables:

```r
PROFDAY
DAY_label
TRTACT_low2high
TRTACT_high2low
```

These variables are used for plotting, grouping, and model preparation.

---

## 2. Binary PD filtering

The binary response endpoint is selected using:

```r
pd_data <- data |>
  filter(CMT == PD_CMT)
```

where:

```r
PD_CMT <- 6
```

The binary endpoint is represented mathematically as:

\[
Y_{ij} \in \{0, 1\}
\]

where:

- \(Y_{ij}\) is the observed binary response for subject \(i\) at observation time \(j\).
- \(Y_{ij} = 1\) means the subject is a responder.
- \(Y_{ij} = 0\) means the subject is a non-responder.

---

## 3. Binomial responder summaries

Responder rates are summarised using exact binomial confidence intervals.

The key helper function is:

```r
summarise_binom()
```

For a group with \(n\) binary observations and \(r\) responders, the empirical responder proportion is:

\[
\hat{p} = \frac{r}{n}
\]

where:

- \(n\) is the number of non-missing binary observations.
- \(r = \sum_{i=1}^{n} Y_i\) is the number of responders.
- \(\hat{p}\) is the observed responder proportion.

The function returns:

- Number of observations.
- Number of responders.
- Response proportion.
- Lower confidence interval.
- Upper confidence interval.

---

## 4. Exploratory plots

The session includes plots for:

- Binary responder rate over time.
- Dose-response at Day 6.
- Dose-response by selected profile days.
- Exposure by binary response.
- Longitudinal responder rate by dose.
- Overall active-treatment responder rate.

---

## 5. Study design summaries

The Quarto document creates a treatment-level summary table containing:

- Number of patients.
- Total number of records.
- Number of PD records.
- Number of dosing records.
- Number of nominal sampling times.
- List of nominal sampling times.

---

# Categorical `nlmixr2` model

## 6. Binary response model

The categorical model describes the probability of binary response using a logit relationship.

The binary outcome is modeled as:

\[
Y_{ij} \sim \operatorname{Bernoulli}(p_{ij})
\]

or equivalently:

\[
Y_{ij} \sim \operatorname{Binomial}(1, p_{ij})
\]

where:

- \(Y_{ij}\) is the binary response for subject \(i\) at time \(j\).
- \(p_{ij}\) is the model-predicted probability that \(Y_{ij} = 1\).
- \(1 - p_{ij}\) is the model-predicted probability that \(Y_{ij} = 0\).

The logit transformation is:

\[
\operatorname{logit}(p_{ij}) = \log \left( \frac{p_{ij}}{1 - p_{ij}} \right)
\]

The inverse-logit transformation is:

\[
p_{ij} = \frac{\exp(\eta_{ij})}{1 + \exp(\eta_{ij})}
\]

or equivalently:

\[
p_{ij} = \frac{1}{1 + \exp(-\eta_{ij})}
\]

where \(\eta_{ij}\) is the linear predictor.

The general form of the model is:

\[
\operatorname{logit}(p_{ij}) =
\beta_0
+ \beta_{\text{trt}} \cdot \text{TRT}_i
+ \beta_{\text{wt}} \cdot \text{WT}_i
+ \beta_{\text{sex}} \cdot \text{SEX}_i
+ \beta_{\text{time}} \cdot t_{ij}
+ b_i
\]

where:

- \(\beta_0\) is the baseline intercept.
- \(\beta_{\text{trt}}\) is a treatment effect.
- \(\beta_{\text{wt}}\) is a body weight effect.
- \(\beta_{\text{sex}}\) is a sex effect.
- \(\beta_{\text{time}}\) is a time effect.
- \(t_{ij}\) is the observation time for subject \(i\) at observation \(j\).
- \(b_i\) is a subject-specific random effect.

The exact model structure depends on the `nlmixr2` model used in the teaching script.

---

# Logic of `vpc_from_nlmixr2_fit.R`

The helper script contains several internal functions and one main plotting function.

Internal helper functions are named with a leading dot, for example:

```r
.normCategoryLabel()
.extractStringComparisons()
.rewriteStringComparisonsToIndicators()
.prepareCategoricalSolveData()
.getFixedEffectsFromFit()
.buildCategoricalSimParams()
```

The main function is:

```r
plot_categorical_vpc_nlmixr2()
```

---

## 7. Label normalization

Function:

```r
.normCategoryLabel()
```

Purpose:

This function converts categorical labels into safe, consistent, machine-readable strings.

For example:

```r
"Female"
```

becomes:

```text
female
```

and:

```r
"High Dose Group"
```

becomes:

```text
high_dose_group
```

The transformation can be written as a normalization function:

\[
N(x)
\]

where \(x\) is an original category label and \(N(x)\) is the normalized label.

The normalization steps are:

1. Convert to character.
2. Remove leading and trailing whitespace.
3. Convert to lowercase.
4. Replace non-alphanumeric characters with underscores.
5. Collapse repeated underscores.
6. Remove leading or trailing underscores.

In code:

```r
.normCategoryLabel <- function(x) {
  x <- as.character(x)
  x <- trimws(x)
  x <- tolower(x)
  x <- gsub("[^[:alnum:]]+", "_", x)
  x <- gsub("_+", "_", x)
  x <- gsub("^_+|_+$", "", x)
  x
}
```

This is needed because `rxode2` model code works more naturally with numeric variables than with direct string comparisons.

---

## 8. Extracting categorical string comparisons from the model

Function:

```r
.extractStringComparisons()
```

Purpose:

This function searches the `nlmixr2` model expressions for comparisons such as:

```r
SEX == "Female"
```

or:

```r
TRTACT == "Dose 100 mg"
```

It extracts four pieces of information:

| Column | Meaning |
|---|---|
| `variable` | The categorical variable name, for example `SEX` |
| `label` | The original string label, for example `"Female"` |
| `normalized` | The normalized label, for example `female` |
| `indicator` | The generated numeric indicator name, for example `SEX_female` |

Mathematically, a string comparison such as:

\[
X_i = \ell
\]

is replaced by an indicator variable:

\[
I_{i,\ell} = \mathbf{1}\{N(X_i) = N(\ell)\}
\]

where:

- \(X_i\) is the observed category for subject or record \(i\).
- \(\ell\) is the category label used in the model.
- \(N(\cdot)\) is the label normalization function.
- \(\mathbf{1}\{\cdot\}\) is the indicator function.
- \(I_{i,\ell} = 1\) if the normalized observed category equals the normalized model label.
- \(I_{i,\ell} = 0\) otherwise.

For example:

```r
SEX == "Female"
```

becomes:

```r
SEX_female
```

where:

\[
\text{SEX\_female}_i =
\mathbf{1}\{N(\text{SEX}_i) = N(\text{Female})\}
\]

---

## 9. Rewriting model expressions for simulation

Function:

```r
.rewriteStringComparisonsToIndicators()
```

Purpose:

This function rewrites the model code so that string comparisons are replaced by numeric indicator variables.

For example, a model expression like:

```r
logit_p1 <- theta0 + theta_sex * (SEX == "Female")
```

is rewritten as:

```r
logit_p1 <- theta0 + theta_sex * SEX_female
```

This matters because simulation with `rxode2::rxSolve()` requires variables that can be supplied numerically in the event or covariate dataset.

The function also removes likelihood lines of the form:

```r
DV ~ binom(...)
```

This is done because the VPC simulation does not refit the likelihood. Instead, it:

1. Evaluates the model-predicted probability.
2. Simulates binary outcomes from that probability.

The function appends a new prediction variable:

```r
rx_pred_ <- p1
```

where `p1` is the default prediction variable. This can be changed using:

```r
pred_var = "p1"
```

The returned object contains:

```r
list(
  model = rxode2::rxode2(...),
  map = .map,
  lines = .txt
)
```

where:

- `model` is an `rxode2` model ready for simulation.
- `map` is the table of extracted categorical comparisons.
- `lines` is the rewritten model code.

---

## 10. Preparing categorical solve data

Function:

```r
.prepareCategoricalSolveData()
```

Purpose:

This function prepares the dataset for `rxode2::rxSolve()`.

It creates standard internal columns:

```r
.id
.time
.dv
```

from user-specified columns:

```r
id_col
time_col
dv_col
```

For example, if:

```r
id_col = "ID"
time_col = "TIME"
dv_col = "DV"
```

then:

```r
.id = ID
.time = TIME
.dv = DV
```

The function also creates numeric indicator columns for each categorical string comparison found in the model.

If the model contains:

```r
SEX == "Female"
```

then the prepared data receives a new column:

```r
SEX_female
```

defined as:

\[
\text{SEX\_female}_{ij}
=
\mathbf{1}\{N(\text{SEX}_{ij}) = N(\text{Female})\}
\]

where:

- \(i\) indexes subjects.
- \(j\) indexes records or observations.
- \(N(\cdot)\) is the normalization function.

Missing indicator values are set to zero.

---

## 11. Extracting fixed effects from the fitted model

Function:

```r
.getFixedEffectsFromFit()
```

Purpose:

This function extracts fixed-effect parameter estimates from the fitted `nlmixr2` object.

It first checks:

```r
fit$parFixedDf
```

If available, it searches for a fixed-effect estimate column named one of:

```text
Est.
Estimate
est
```

If `fit$parFixedDf` is unavailable, it tries:

```r
fit$parFixed
```

The extracted fixed-effect vector can be written as:

\[
\hat{\boldsymbol{\theta}}
\]

where:

- \(\hat{\boldsymbol{\theta}}\) is the vector of estimated population-level fixed effects.
- Each component \(\hat{\theta}_k\) corresponds to one fixed-effect parameter.

---

## 12. Simulating random effects

Function:

```r
.buildCategoricalSimParams()
```

Purpose:

This helper builds a parameter dataset for simulation by combining:

1. Fixed-effect estimates.
2. Simulated subject-level random effects.

The random effects are simulated from a multivariate normal distribution:

\[
\boldsymbol{\eta}_i \sim \mathcal{N}(\mathbf{0}, \hat{\boldsymbol{\Omega}})
\]

where:

- \(\boldsymbol{\eta}_i\) is the vector of random effects for subject \(i\).
- \(\mathbf{0}\) is a vector of zeros.
- \(\hat{\boldsymbol{\Omega}}\) is the estimated random-effect covariance matrix from the fitted model.
- \(i = 1, \dots, N\), where \(N\) is the number of subjects.

In the code, the covariance matrix is taken from:

```r
fit$omega
```

and random effects are simulated using:

```r
MASS::mvrnorm()
```

The resulting simulation parameter table contains one row per subject.

---

# Main categorical VPC function

## 13. `plot_categorical_vpc_nlmixr2()`

Main function:

```r
plot_categorical_vpc_nlmixr2()
```

Purpose:

This function generates a categorical visual predictive check for a fitted binary `nlmixr2` model.

It compares:

- The empirical observed responder probability.
- The model-predicted median simulated responder probability.
- The simulated prediction interval.

---

## 14. Function arguments

```r
plot_categorical_vpc_nlmixr2(
  fit,
  data,
  id_col = "ID",
  time_col = "TIME",
  dv_col = "DV",
  pred_var = "p1",
  nBins = 10,
  nSim = 200,
  ci = 0.95,
  seed = 12345,
  x_transform = function(x) x / 24,
  xlab = "Time (days)",
  ylab = "P(Y = 1)",
  title = "Categorical VPC"
)
```

| Argument | Meaning |
|---|---|
| `fit` | Fitted `nlmixr2` model object |
| `data` | Dataset used for VPC simulation and empirical summaries |
| `id_col` | Subject identifier column |
| `time_col` | Time column |
| `dv_col` | Binary dependent variable column |
| `pred_var` | Model variable containing predicted probability |
| `nBins` | Number of time bins |
| `nSim` | Number of simulation replicates |
| `ci` | Prediction interval level |
| `seed` | Random seed for reproducibility |
| `x_transform` | Function used to transform time for plotting |
| `xlab` | X-axis label |
| `ylab` | Y-axis label |
| `title` | Plot title |

---

## 15. Step-by-step VPC algorithm

The function performs the following steps.

### Step 1: Set random seed

```r
set.seed(seed)
```

This helps make simulation results reproducible.

---

### Step 2: Check required columns

The function verifies that the required columns exist in the input data:

```r
id_col
time_col
dv_col
```

If any are missing, the function stops with an error.

---

### Step 3: Extract model expressions

The fitted `nlmixr2` model is decompressed using:

```r
ui <- rxode2::rxUiDecompress(fit)
exprs <- ui$lstExpr
```

The object `exprs` contains model expressions from the fitted object.

---

### Step 4: Rewrite categorical comparisons

The model expressions are rewritten using:

```r
pred_info <- .rewriteStringComparisonsToIndicators(exprs, pred_var = pred_var)
pred_model <- pred_info$model
```

This replaces string comparisons such as:

```r
SEX == "Female"
```

with numeric indicator variables such as:

```r
SEX_female
```

This rewritten model is then suitable for simulation with `rxode2`.

---

### Step 5: Prepare the data

The input data are prepared using:

```r
prep <- .prepareCategoricalSolveData(
  data = data,
  exprs = exprs,
  id_col = id_col,
  time_col = time_col,
  dv_col = dv_col
)
```

The prepared data contain:

- Numeric subject IDs.
- Time.
- Binary observed response.
- Any needed numeric categorical indicators.

The plotting time is calculated as:

```r
time_plot = x_transform(.time)
```

For example, if the original time is in hours, then:

```r
x_transform = function(x) x / 24
```

converts time to days.

---

### Step 6: Build the solve dataset

The function identifies which model parameters are present in the data:

```r
needed_from_data <- pred_model$params[pred_model$params %in% names(dat)]
```

Then it creates the event or covariate dataset for `rxSolve()`:

```r
solve_data <- dat %>%
  dplyr::select(dplyr::all_of(unique(c("id", "time", "DV", needed_from_data))))
```

This ensures that the solver receives only the columns needed for prediction.

---

### Step 7: Define time bins

The transformed plotting time is divided into `nBins` bins:

```r
breaks <- seq(t_range_plot[1], t_range_plot[2], length.out = nBins + 1)
```

Each observation is assigned to a time bin:

```r
timeBin = cut(time_plot, breaks = breaks, include.lowest = TRUE)
```

Mathematically, let the time bins be:

\[
B_1, B_2, \dots, B_K
\]

where:

- \(K =\) `nBins`.
- Each \(B_k\) is an interval of transformed time.
- Each observation belongs to one bin.

---

### Step 8: Compute empirical responder probabilities

For each time bin \(B_k\), the empirical observed responder probability is:

\[
\hat{p}^{\text{obs}}_k =
\frac{1}{n_k}
\sum_{(i,j): t_{ij} \in B_k}
Y_{ij}
\]

where:

- \(\hat{p}^{\text{obs}}_k\) is the observed responder probability in bin \(k\).
- \(n_k\) is the number of observed binary responses in bin \(k\).
- \(Y_{ij}\) is the observed binary response for subject \(i\) at time \(j\).
- \(t_{ij}\) is the observation time.

In code:

```r
emp_prob <- emp_dat %>%
  dplyr::group_by(timeBin) %>%
  dplyr::summarise(
    empirical = mean(DV, na.rm = TRUE),
    .groups = "drop"
  )
```

---

### Step 9: Simulate random effects

For each simulation replicate \(s\), subject-level random effects are drawn:

\[
\boldsymbol{\eta}_i^{(s)}
\sim
\mathcal{N}(\mathbf{0}, \hat{\boldsymbol{\Omega}})
\]

where:

- \(s = 1, \dots, S\).
- \(S =\) `nSim`.
- \(i = 1, \dots, N\).
- \(N\) is the number of subjects.
- \(\hat{\boldsymbol{\Omega}}\) is the estimated random-effect covariance matrix.

In code:

```r
eta_draw <- MASS::mvrnorm(
  n = length(ids),
  mu = rep(0, length(eta_names)),
  Sigma = omega_mat
)
```

---

### Step 10: Simulate model-predicted probabilities

For each simulation replicate, `rxode2::rxSolve()` evaluates the fitted model using:

- Fixed effects.
- Simulated random effects.
- Observed time points.
- Observed covariate values.

```r
sim_solve <- rxode2::rxSolve(
  pred_model,
  params = sim_params,
  events = solve_data %>%
    dplyr::select(-DV),
  returnType = "data.frame",
  covsInterpolation = "locf",
  omega = NULL,
  addDosing = FALSE
)
```

The output contains:

```r
rx_pred_
```

which is the predicted binary response probability.

Mathematically, this is:

\[
p_{ij}^{(s)} =
P(Y_{ij}^{(s)} = 1 \mid \hat{\boldsymbol{\theta}}, \boldsymbol{\eta}_i^{(s)}, \mathbf{x}_{ij})
\]

where:

- \(p_{ij}^{(s)}\) is the predicted response probability for subject \(i\), time \(j\), simulation \(s\).
- \(\hat{\boldsymbol{\theta}}\) is the vector of fixed-effect estimates.
- \(\boldsymbol{\eta}_i^{(s)}\) is the simulated random-effect vector.
- \(\mathbf{x}_{ij}\) is the covariate vector.

---

### Step 11: Simulate binary outcomes

For each predicted probability, a simulated binary outcome is drawn:

\[
Y_{ij}^{(s)} \sim \operatorname{Bernoulli}(p_{ij}^{(s)})
\]

In code:

```r
simDV = stats::rbinom(
  n = dplyr::n(),
  size = 1,
  prob = pmin(pmax(pred, 1e-10), 1 - 1e-10)
)
```

The probability is clipped to avoid exact values of 0 or 1:

\[
p_{ij,\text{clipped}}^{(s)}
=
\min\left(
\max\left(p_{ij}^{(s)}, 10^{-10}\right),
1 - 10^{-10}
\right)
\]

This numerical safeguard prevents simulation issues when probabilities are extremely close to 0 or 1.

---

### Step 12: Compute simulated responder proportions

For each simulation replicate \(s\) and each time bin \(B_k\), the simulated responder proportion is:

\[
\hat{p}^{(s)}_k =
\frac{1}{n_k^{(s)}}
\sum_{(i,j): t_{ij} \in B_k}
Y_{ij}^{(s)}
\]

where:

- \(\hat{p}^{(s)}_k\) is the simulated responder proportion in bin \(k\) for simulation \(s\).
- \(Y_{ij}^{(s)}\) is the simulated binary response.
- \(n_k^{(s)}\) is the number of simulated observations in bin \(k\).

In code:

```r
sim_df <- sim_df %>%
  dplyr::group_by(timeBin) %>%
  dplyr::summarise(
    simProp = mean(simDV),
    .groups = "drop"
  )
```

---

### Step 13: Compute prediction intervals

For each time bin, the function computes the lower, median, and upper quantiles of the simulated responder proportions.

If the requested prediction interval is:

\[
100 \times \text{ci}\%
\]

then:

\[
\alpha = \frac{1 - \text{ci}}{2}
\]

The lower and upper prediction interval bounds are:

\[
Q_{\alpha}
\]

and:

\[
Q_{1-\alpha}
\]

For example, if:

```r
ci = 0.95
```

then:

\[
\alpha = \frac{1 - 0.95}{2} = 0.025
\]

and the prediction interval is bounded by the 2.5th and 97.5th percentiles.

In code:

```r
alpha <- (1 - ci) / 2

pi_df <- sim_res %>%
  dplyr::group_by(timeBin, timeMid) %>%
  dplyr::summarise(
    piLow = stats::quantile(simProp, probs = alpha, na.rm = TRUE),
    piMed = stats::quantile(simProp, probs = 0.5, na.rm = TRUE),
    piHigh = stats::quantile(simProp, probs = 1 - alpha, na.rm = TRUE),
    .groups = "drop"
  )
```

---

### Step 14: Create the VPC plot

The final plot contains:

- A shaded prediction interval.
- A solid line for the empirical observed responder probability.
- A dashed line for the simulated median responder probability.

The plot is created with `ggplot2`.

Interpretation:

- If the empirical line lies mostly inside the prediction interval, the model is broadly consistent with the observed binary response trend.
- If the empirical line systematically lies outside the prediction interval, the model may be missing important structure.
- If the predicted median is consistently above or below the empirical line, the model may overpredict or underpredict the response probability.

---

# Categorical VPC interpretation

The categorical VPC compares observed and simulated responder rates over time.

For each time bin \(B_k\), the plot shows:

\[
\hat{p}^{\text{obs}}_k
\]

as the empirical observed responder probability.

It also shows:

\[
\operatorname{median}\left(
\hat{p}^{(1)}_k,
\hat{p}^{(2)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
\]

as the model-predicted median responder probability.

The shaded region shows:

\[
\left[
Q_{\alpha}
\left(
\hat{p}^{(1)}_k,
\dots,
\hat{p}^{(S)}_k
\right),
Q_{1-\alpha}
\left(
\hat{p}^{(1)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
\right]
\]

where:

- \(S\) is the number of simulations.
- \(Q_{\alpha}\) is the lower quantile.
- \(Q_{1-\alpha}\) is the upper quantile.
- \(\alpha = (1 - \text{ci}) / 2\).

---

# Important assumptions

The helper function assumes:

1. The fitted model object contains fixed effects in `fit$parFixedDf` or `fit$parFixed`.
2. The fitted model object contains a random-effect covariance matrix in `fit$omega`.
3. The rows and columns of `fit$omega` are named.
4. The model-predicted binary response probability is available as `pred_var`, defaulting to `p1`.
5. The dependent variable is binary and coded as 0 or 1.
6. Any categorical string comparisons in the model are present as columns in the input data.
7. The same covariate names used in the model are available in the data passed to `plot_categorical_vpc_nlmixr2()`.

---

# Common integration errors and fixes

## Missing categorical variable

Error example:

```text
Required categorical variable missing from data
```

Cause:

The model contains a comparison such as:

```r
SEX == "Female"
```

but the column `SEX` is not present in the dataset passed to the VPC function.

Fix:

Make sure the data contains the original categorical column:

```r
names(modeling_data)
```

---

## Missing omega row names

Error example:

```text
Omega matrix row names are required
```

Cause:

The random-effect covariance matrix does not have row names.

Fix:

Check:

```r
fit$omega
```

The row names should correspond to the random-effect names used by the model.

---

## Predicted probability variable not found

Cause:

The model-predicted probability may not be named `p1`.

Fix:

Pass the correct prediction variable name:

```r
plot_categorical_vpc_nlmixr2(
  fit = fit,
  data = modeling_data,
  pred_var = "your_probability_variable"
)
```

For example, if the model uses:

```r
p_resp <- expit(logit_p_resp)
```

then use:

```r
pred_var = "p_resp"
```

---

## Time scale is wrong

Cause:

The input `TIME` may be in hours, but the desired plot is in days.

Fix:

Use:

```r
x_transform = function(x) x / 24
```

If the input time is already in days, use:

```r
x_transform = function(x) x
```

---

# Reproducibility

The analysis uses a fixed random seed:

```r
set.seed(12345)
```

The same seed is also used in the categorical VPC simulation:

```r
seed = 12345
```

This helps make the output reproducible across runs, although small differences may still occur across package versions or operating systems.

---

# Suggested citation or acknowledgement

This teaching material uses the `mad` example dataset from the `xgxr` R package and demonstrates modeling workflows using `nlmixr2` and `rxode2`.

---

# License

```text
MIT License
```
