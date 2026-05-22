# Multiple Ascending Dose PK/PD Binary Response Hands-on Session

This repository contains teaching material for a hands-on pharmacometrics session using a simulated multiple ascending dose PK/PD dataset.

The session focuses on exploratory analysis, binary pharmacodynamic response summaries, dose-response visualisation, longitudinal responder-rate analysis, categorical modeling using `nlmixr2`, and categorical visual predictive checks.

The main endpoint is a binary pharmacodynamic response, where each observation is either a responder or a non-responder.

$$
Y = 1
$$

means responder, and:

$$
Y = 0
$$

means non-responder.

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

Helper R script containing utility functions for generating a categorical visual predictive check, or categorical VPC, from an `nlmixr2` fit.

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

## Main analysis steps

### 1. Data preparation

The Quarto document creates additional analysis variables:

```r
PROFDAY
DAY_label
TRTACT_low2high
TRTACT_high2low
```

These variables are used for plotting, grouping, longitudinal summaries, and model preparation.

### 2. Binary PD filtering

The binary pharmacodynamic response endpoint is selected using:

```r
pd_data <- data |>
  filter(CMT == PD_CMT)
```

where:

```r
PD_CMT <- 6
```

The binary response for subject $i$ at observation $j$ is represented as:

$$
Y_{ij} \in \{0, 1\}
$$

where:

- $Y_{ij} = 1$ means subject $i$ is a responder at observation $j$.
- $Y_{ij} = 0$ means subject $i$ is a non-responder at observation $j$.

### 3. Binomial responder summaries

Responder rates are summarised using exact binomial confidence intervals.

The key helper function is:

```r
summarise_binom()
```

For a group with $n$ binary observations and $r$ responders, the empirical responder proportion is:

$$
\hat{p} = \frac{r}{n}
$$

where:

- $n$ is the number of non-missing binary observations.
- $r = \sum_{i=1}^{n} Y_i$ is the number of responders.
- $\hat{p}$ is the observed responder proportion.

The function returns:

- Number of observations.
- Number of responders.
- Response proportion.
- Lower confidence interval.
- Upper confidence interval.

The exact binomial confidence interval is different from the VPC prediction interval.

The confidence interval summarizes uncertainty around an observed responder probability.

The VPC prediction interval summarizes the distribution of simulated responder proportions under the fitted model.

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

### 6. Categorical modeling

The categorical model describes the probability of binary response using a logit relationship.

The model estimates the response probability:

$$
p_{ij} = \mathrm{P}(Y_{ij} = 1)
$$

and uses this probability to describe the binary endpoint:

$$
Y_{ij} \sim \mathrm{Bernoulli}(p_{ij})
$$

The fitted model is then used to generate a categorical VPC.

---

## `nlmixr2` binary response model

The categorical model describes the probability of binary response using a logit relationship.

For subject $i$ at observation $j$, the binary response is:

$$
Y_{ij} \in \{0, 1\}
$$

where:

- $Y_{ij} = 1$ means subject $i$ is a responder at observation $j$.
- $Y_{ij} = 0$ means subject $i$ is a non-responder at observation $j$.

The model-predicted probability of response is:

$$
p_{ij} = \mathrm{P}(Y_{ij} = 1)
$$

The binary outcome is modeled as:

$$
Y_{ij} \sim \mathrm{Bernoulli}(p_{ij})
$$

or equivalently:

$$
Y_{ij} \sim \mathrm{Binomial}(1, p_{ij})
$$

The logit transformation is:

$$
\mathrm{logit}(p_{ij}) =
\log \left(\frac{p_{ij}}{1 - p_{ij}}\right)
$$

The inverse-logit transformation is:

$$
p_{ij} =
\frac{1}{1 + \exp(-\eta_{ij})}
$$

where $\eta_{ij}$ is the linear predictor.

A general binary response model can be written as:

$$
\mathrm{logit}(p_{ij}) = \beta_0 + \beta_{trt}\mathrm{TRT}_i + \beta_{wt}\mathrm{WT}_i + \beta_{sex}\mathrm{SEX}_i + \beta_{time}t_{ij} + b_i
$$

where:

where:

- $\beta_0$ is the baseline intercept.
- $\beta_{\mathrm{trt}}$ is a treatment effect.
- $\beta_{\mathrm{wt}}$ is a body weight effect.
- $\beta_{\mathrm{sex}}$ is a sex effect.
- $\beta_{\mathrm{time}}$ is a time effect.
- $t_{ij}$ is the observation time for subject $i$ at observation $j$.
- $b_i$ is a subject-specific random effect.

The exact model structure depends on the `nlmixr2` model used in the teaching script.

---

## Logic of `vpc_from_nlmixr2_fit.R`

The helper script contains internal utility functions and one main user-facing plotting function.

Internal helper functions are named with a leading dot:

```r
.normCategoryLabel()
.extractStringComparisons()
.rewriteStringComparisonsToIndicators()
.prepareCategoricalSolveData()
.getFixedEffectsFromFit()
.buildCategoricalSimParams()
```

The main user-facing function is:

```r
plot_categorical_vpc_nlmixr2()
```

The function generates a categorical VPC from a fitted `nlmixr2` binary response model.

It compares:

- The empirical observed responder probability.
- The model-predicted median simulated responder probability.
- A simulation-based prediction interval for the binned responder proportion.

The shaded interval in the VPC is not a confidence interval for the observed data.

It is a prediction interval obtained from repeated simulations under the fitted model.

It answers the question:

> If the fitted model were true, and the same study design were repeated many times, what range of responder proportions would we expect in each time bin?

---

## Label normalization

Function:

```r
.normCategoryLabel()
```

Purpose:

This function converts categorical labels into safe, consistent, machine-readable strings.

For example:

```text
"Female" -> "female"
"High Dose Group" -> "high_dose_group"
"Dose 100 mg" -> "dose_100_mg"
```

The normalization function is denoted as:

$$
N(x)
$$

where:

- $x$ is the original category label.
- $N(x)$ is the normalized label.

The normalization steps are:

1. Convert values to character.
2. Remove leading and trailing whitespace.
3. Convert text to lowercase.
4. Replace non-alphanumeric characters with underscores.
5. Collapse repeated underscores.
6. Remove leading and trailing underscores.

This is needed because `rxode2::rxSolve()` works more naturally with numeric covariates than with direct string comparisons.

---

## Categorical string comparisons and indicator variables

Some `nlmixr2` models may contain categorical string comparisons, for example:

```r
SEX == "Female"
```

or:

```r
TRTACT == "Dose 100 mg"
```

These comparisons are convenient in model code, but they are not ideal for direct simulation with `rxode2::rxSolve()`.

The helper script therefore converts string comparisons into numeric indicator variables.

For example:

```r
SEX == "Female"
```

is rewritten as:

```r
SEX_female
```

Mathematically, this categorical comparison is converted into an indicator variable:

$$
\mathrm{SEX\_female}_i = \mathbf{1}\{N(\mathrm{SEX}_i) = N(\mathrm{Female})\}
$$

where:

- $N(\cdot)$ is the label-normalization function.
- $\mathbf{1}\{\cdot\}$ is an indicator function.
- $\mathrm{SEX\_female}_i = 1$ if subject or record $i$ has normalized sex label `"female"`.
- $\mathrm{SEX\_female}_i = 0$ otherwise.

More generally, a categorical comparison:

$$
X_i = \ell
$$

is replaced by:

$$
I_{i,\ell} =
\mathbf{1}\left\{N(X_i) = N(\ell)\right\}
$$

where:

- $X_i$ is the observed categorical value for subject or record $i$.
- $\ell$ is the category label used in the model.
- $I_{i,\ell}$ is the numeric indicator variable.

---

## Extracting categorical string comparisons

Function:

```r
.extractStringComparisons()
```

Purpose:

This function searches the `nlmixr2` model expressions for string comparisons.

Examples include:

```r
SEX == "Female"
```

and:

```r
TRTACT == "Dose 100 mg"
```

For each comparison, it extracts:

- The categorical variable name.
- The original string label.
- The normalized label.
- The generated indicator-variable name.

For example, from:

```r
SEX == "Female"
```

the function creates:

```text
variable: SEX
label: Female
normalized: female
indicator: SEX_female
```

This mapping is later used to rewrite the model and prepare the simulation data.

---

## Rewriting model expressions for simulation

Function:

```r
.rewriteStringComparisonsToIndicators()
```

Purpose:

This function rewrites model code so that categorical string comparisons are replaced by numeric indicator variables.

For example, a model expression like:

```r
logit_p1 <- theta0 + theta_sex * (SEX == "Female")
```

is rewritten as:

```r
logit_p1 <- theta0 + theta_sex * SEX_female
```

The function also removes likelihood lines such as:

```r
DV ~ binom(...)
```

This is done because the VPC simulation does not refit the likelihood.

Instead, the function:

1. Evaluates the model-predicted probability.
2. Simulates binary outcomes from that probability.
3. Summarises the simulated binary outcomes by time bin.

The function appends a prediction variable:

```r
rx_pred_ <- p1
```

where `p1` is the default predicted probability variable.

If your model uses a different probability variable, pass it through:

```r
pred_var = "your_probability_variable"
```

The function returns a list containing:

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

## Preparing categorical solve data

Function:

```r
.prepareCategoricalSolveData()
```

Purpose:

This function prepares the input dataset for `rxode2::rxSolve()`.

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

$$
\mathrm{SEX\_female}_{ij} =
\mathbf{1}\left\{N(\mathrm{SEX}_{ij}) = N(\mathrm{Female})\right\}
$$

where:

- $i$ indexes subjects.
- $j$ indexes records or observations.
- $N(\cdot)$ is the normalization function.

Missing indicator values are set to zero.

---

## Extracting fixed effects

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

The extracted fixed-effect vector is denoted as:

$$
\hat{\boldsymbol{\theta}}
$$

where each component $\hat{\theta}_k$ is one estimated population-level parameter.

---

## Fixed effects and random effects used in the VPC

The helper function extracts the estimated random-effect covariance matrix:

$$
\hat{\boldsymbol{\Omega}}
$$

from:

```r
fit$omega
```

For each simulation replicate, subject-specific random effects are sampled as:

$$
\boldsymbol{\eta}_i^{(s)}
\sim
\mathrm{Normal}(\mathbf{0}, \hat{\boldsymbol{\Omega}})
$$

where:

- $\boldsymbol{\eta}_i^{(s)}$ is the vector of random effects for subject $i$ in simulation $s$.
- $\mathbf{0}$ is a vector of zeros.
- $\hat{\boldsymbol{\Omega}}$ is the estimated random-effect covariance matrix.
- $s = 1, \dots, S$, where $S$ is the number of simulations.

Random effects are simulated using:

```r
MASS::mvrnorm()
```

---

## Building simulation parameters

Function:

```r
.buildCategoricalSimParams()
```

Purpose:

This helper builds a parameter dataset for simulation by combining:

- Fixed-effect estimates.
- Simulated subject-level random effects.

The resulting simulation parameter table contains one row per subject.

Each row includes:

- Subject ID.
- Fixed-effect parameter values.
- Simulated random-effect values.

Although this helper exists in the script, the main VPC function also performs similar simulation-parameter construction internally for each replicate.

---

## Categorical VPC

The categorical VPC compares observed and model-simulated responder probabilities over time.

The helper function used is:

```r
plot_categorical_vpc_nlmixr2()
```

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

The argument `pred_var` should identify the model variable containing the predicted probability of response.

In this example, the predicted probability variable is:

```r
p1
```

---

## Categorical VPC algorithm

### Step 1: Set the random seed

The function begins with:

```r
set.seed(seed)
```

This helps make the simulation reproducible.

---

### Step 2: Check required columns

The function verifies that the input dataset contains:

```r
id_col
time_col
dv_col
```

For example:

```r
ID
TIME
DV
```

If any required columns are missing, the function stops with an error.

---

### Step 3: Extract model expressions

The fitted `nlmixr2` model is decompressed using:

```r
ui <- rxode2::rxUiDecompress(fit)
exprs <- ui$lstExpr
```

The object `exprs` contains the model expressions from the fitted object.

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

The rewritten model can then be evaluated by `rxode2`.

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
- Numeric categorical indicators needed by the model.

The plotting time is calculated as:

```r
time_plot = x_transform(.time)
```

If the original time is in hours and the desired plot scale is days, use:

```r
x_transform = function(x) x / 24
```

If the input time is already in days, use:

```r
x_transform = function(x) x
```

---

### Step 6: Bin time

The transformed plotting time is divided into $K$ bins:

$$
B_1, B_2, \dots, B_K
$$

where $K$ is controlled by:

```r
nBins
```

For example:

```r
nBins = 10
```

creates 10 time bins.

Each observation is assigned to a bin using:

```r
timeBin = cut(time_plot, breaks = breaks, include.lowest = TRUE)
```

---

### Step 7: Compute the observed responder proportion

For each time bin $B_k$, the empirical observed responder proportion is:

$$
\hat{p}^{\mathrm{obs}}_k =
\frac{1}{n_k}
\sum_{(i,j): t_{ij} \in B_k}
Y_{ij}
$$

where:

- $\hat{p}^{\mathrm{obs}}_k$ is the observed responder proportion in bin $k$.
- $n_k$ is the number of observations in bin $k$.
- $Y_{ij}$ is the observed binary response for subject $i$ at observation $j$.
- $t_{ij}$ is the observation time.
- $B_k$ is time bin $k$.

Because `DV` is coded as 0 or 1, the mean of `DV` within a bin is the responder proportion.

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

### Step 8: Simulate replicate datasets

For each simulation replicate $s$, where:

$$
s = 1, \dots, S
$$

and $S$ is the number of simulations, the function draws subject-level random effects:

$$
\boldsymbol{\eta}_i^{(s)}
\sim
\mathrm{Normal}(\mathbf{0}, \hat{\boldsymbol{\Omega}})
$$

Then the model computes predicted probabilities:

$$
p_{ij}^{(s)}
=
\mathrm{P}
\left(
Y_{ij}^{(s)} = 1
\mid
\hat{\boldsymbol{\theta}},
\boldsymbol{\eta}_i^{(s)},
\mathbf{x}_{ij}
\right)
$$

where:

- $p_{ij}^{(s)}$ is the predicted response probability for subject $i$ at observation $j$ in simulation $s$.
- $\hat{\boldsymbol{\theta}}$ is the vector of estimated fixed effects.
- $\boldsymbol{\eta}_i^{(s)}$ is the simulated random-effect vector for subject $i$.
- $\mathbf{x}_{ij}$ is the covariate vector.
- $Y_{ij}^{(s)}$ is the simulated binary response.

Then simulated binary responses are drawn as:

$$
Y_{ij}^{(s)}
\sim
\mathrm{Bernoulli}\left(p_{ij}^{(s)}\right)
$$

In the code, this is done with:

```r
simDV = stats::rbinom(
  n = dplyr::n(),
  size = 1,
  prob = pmin(pmax(pred, 1e-10), 1 - 1e-10)
)
```

The probability is clipped to avoid exact values of 0 or 1:

$$
p_{ij,\mathrm{clipped}}^{(s)}
=
\min \left[
\max \left(p_{ij}^{(s)}, 10^{-10}\right),
1 - 10^{-10}
\right]
$$

This is a numerical safeguard.

---

### Step 9: Compute simulated responder proportions

For each simulation replicate $s$ and time bin $B_k$, the simulated responder proportion is:

$$
\hat{p}^{(s)}_k =
\frac{1}{n_k}
\sum_{(i,j): t_{ij} \in B_k}
Y_{ij}^{(s)}
$$

where:

- $\hat{p}^{(s)}_k$ is the simulated responder proportion in bin $k$ for simulation $s$.
- $Y_{ij}^{(s)}$ is the simulated binary response.
- $n_k$ is the number of simulated observations in bin $k$.

After $S$ simulations, each time bin has a distribution of simulated responder proportions:

$$
\hat{p}^{(1)}_k,
\hat{p}^{(2)}_k,
\dots,
\hat{p}^{(S)}_k
$$

---

### Step 10: Compute the simulation-based prediction interval

The shaded band in the categorical VPC is a simulation-based prediction interval for the binned responder proportion.

For a central $100 \times \mathrm{ci}\%$ prediction interval:

$$
\alpha = \frac{1 - \mathrm{ci}}{2}
$$

The lower prediction interval bound is:

$$
\mathrm{PI}_{k,\mathrm{low}}
=
Q_{\alpha}
\left(
\hat{p}^{(1)}_k,
\hat{p}^{(2)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
$$

The upper prediction interval bound is:

$$
\mathrm{PI}_{k,\mathrm{high}}
=
Q_{1-\alpha}
\left(
\hat{p}^{(1)}_k,
\hat{p}^{(2)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
$$

The simulated median is:

$$
\mathrm{PI}_{k,\mathrm{median}}
=
Q_{0.5}
\left(
\hat{p}^{(1)}_k,
\hat{p}^{(2)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
$$

where $Q_q$ is the empirical quantile at probability $q$.

For example, if:

```r
ci = 0.95
```

then:

$$
\alpha = \frac{1 - 0.95}{2} = 0.025
$$

and the prediction interval uses the 2.5th and 97.5th percentiles:

$$
\mathrm{PI}_{k,\mathrm{low}}
=
Q_{0.025}
\left(
\hat{p}^{(1)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
$$

$$
\mathrm{PI}_{k,\mathrm{high}}
=
Q_{0.975}
\left(
\hat{p}^{(1)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
$$

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

### Step 11: Create the VPC plot

The final plot contains:

- A shaded prediction interval for the simulated binned responder proportions.
- A solid line for the empirical observed responder probability.
- A dashed line for the simulated median responder probability.

The shaded interval can be described as:

> A 95% simulation-based prediction interval for the binned responder proportion.

This means that, under the fitted model, approximately 95% of simulated binned responder proportions are expected to fall within the shaded band.

If the empirical observed responder probability lies mostly inside the prediction interval, the model is broadly consistent with the observed time trend.

If the empirical line systematically lies outside the prediction interval, the model may be overpredicting, underpredicting, or missing important structure.

---

## Code-to-statistics mapping for the categorical VPC

This section maps the main code objects in `plot_categorical_vpc_nlmixr2()` to the statistical quantities used in the VPC.

- `DV`: observed binary response.
- `pred`: model-predicted response probability.
- `simDV`: simulated binary response.
- `timeBin`: time bin.
- `empirical`: observed responder proportion.
- `simProp`: simulated responder proportion.
- `piLow`: lower prediction interval bound.
- `piMed`: median simulated responder proportion.
- `piHigh`: upper prediction interval bound.
- `nSim`: number of simulated replicate datasets.
- `nBins`: number of time bins.
- `ci`: central prediction interval level.

In notation:

- `DV` corresponds to $Y_{ij}$.
- `pred` corresponds to $p_{ij}^{(s)}$.
- `simDV` corresponds to $Y_{ij}^{(s)}$.
- `timeBin` corresponds to $B_k$.
- `empirical` corresponds to $\hat{p}^{\mathrm{obs}}_k$.
- `simProp` corresponds to $\hat{p}^{(s)}_k$.
- `piLow` corresponds to $\mathrm{PI}_{k,\mathrm{low}}$.
- `piMed` corresponds to $\mathrm{PI}_{k,\mathrm{median}}$.
- `piHigh` corresponds to $\mathrm{PI}_{k,\mathrm{high}}$.
- `nSim` corresponds to $S$.
- `nBins` corresponds to $K$.

The empirical observed responder proportion is calculated from the original data:

$$
\hat{p}^{\mathrm{obs}}_k =
\frac{1}{n_k}
\sum_{(i,j): t_{ij} \in B_k}
Y_{ij}
$$

The simulated responder proportion is calculated separately for each simulation replicate:

$$
\hat{p}^{(s)}_k =
\frac{1}{n_k}
\sum_{(i,j): t_{ij} \in B_k}
Y_{ij}^{(s)}
$$

The prediction interval is then calculated from the empirical quantiles of the simulated proportions:

$$
\mathrm{PI}_{k,\mathrm{low}}
=
Q_{\alpha}
\left(
\hat{p}^{(1)}_k,
\hat{p}^{(2)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
$$

$$
\mathrm{PI}_{k,\mathrm{high}}
=
Q_{1-\alpha}
\left(
\hat{p}^{(1)}_k,
\hat{p}^{(2)}_k,
\dots,
\hat{p}^{(S)}_k
\right)
$$

where:

$$
\alpha = \frac{1 - \mathrm{ci}}{2}
$$

---

## Prediction interval versus confidence interval

The teaching session uses both confidence intervals and prediction intervals, but they answer different questions.

### Confidence interval

A confidence interval describes uncertainty about an unknown parameter.

For example, for $r$ responders out of $n$ observations, the observed responder proportion is:

$$
\hat{p} = \frac{r}{n}
$$

An exact binomial confidence interval gives a plausible range for the true underlying response probability.

It answers:

> Given the observed data, what is a plausible range for the true responder probability?

### Prediction interval

The categorical VPC prediction interval describes variability in replicated data simulated under the fitted model.

It answers:

> If the fitted model generated many new datasets with the same design, what range of binned responder proportions would we expect?

Therefore, the VPC shaded band should be described as a prediction interval, not as a confidence interval.

The current implementation treats the fitted fixed effects as fixed at their estimates and simulates random effects and binary outcomes.

It does not fully propagate fixed-effect parameter uncertainty.

---

## What the categorical VPC does and does not show

The categorical VPC is a model evaluation plot.

It shows whether the fitted model can reproduce the observed responder-rate trend over time.

The VPC shows:

- The observed responder proportion in each time bin.
- The median responder proportion from simulated replicate datasets.
- The expected simulation variability in responder proportions.

The VPC does not directly show:

- Individual-level prediction errors.
- A formal hypothesis test.
- A confidence interval for the observed responder proportion.
- Full fixed-effect parameter uncertainty, unless this is explicitly added to the simulation procedure.

In the current implementation, the fixed-effect estimates are treated as fixed at:

$$
\hat{\boldsymbol{\theta}}
$$

and random effects are sampled from:

$$
\boldsymbol{\eta}_i^{(s)}
\sim
\mathrm{Normal}(\mathbf{0}, \hat{\boldsymbol{\Omega}})
$$

Therefore, the VPC prediction interval includes variability from:

- Simulated subject-level random effects.
- Simulated binary response outcomes.
- The study design and observation schedule.
- The binning procedure.

It does not fully propagate uncertainty in the estimated fixed effects or the estimated random-effect covariance matrix.

---

## How to describe the VPC result

Recommended wording:

> The shaded region is a 95% simulation-based prediction interval for the binned responder proportion. It was obtained by simulating replicate datasets from the fitted model, computing responder proportions in each time bin, and taking the 2.5th and 97.5th percentiles of those simulated proportions.

Short wording:

> The shaded band is the 95% VPC prediction interval for the simulated responder rate.

Avoid saying:

> The shaded band is the 95% confidence interval of the observed responder rate.

That wording is not correct for this plot because the shaded band describes simulated replicated data, not uncertainty around the observed responder proportion.

---

## Common integration errors and fixes

### Missing categorical variable

Example error:

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

Check that the data contains the original categorical column:

```r
names(modeling_data)
```

---

### Missing omega row names

Example error:

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

### Predicted probability variable not found

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
p_resp <- 1 / (1 + exp(-logit_p_resp))
```

then use:

```r
pred_var = "p_resp"
```

---

### Time scale is wrong

Cause:

The input `TIME` may be in hours, but the desired plot scale may be days.

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

---

## Suggested citation or acknowledgement

This teaching material uses the `mad` example dataset from the `xgxr` R package and demonstrates modeling workflows using `nlmixr2` and `rxode2`.

---

## License

```text
MIT License
```
