.normCategoryLabel <- function(x) {
  x <- as.character(x)
  x <- trimws(x)
  x <- tolower(x)
  x <- gsub("[^[:alnum:]]+", "_", x)
  x <- gsub("_+", "_", x)
  x <- gsub("^_+|_+$", "", x)
  x
}

.extractStringComparisons <- function(exprs) {
  .txt <- vapply(exprs, deparse1, character(1))
  .pat <- "([[:alnum:]_]+)\\s*==\\s*['\"]([^'\"]+)['\"]"
  
  .res <- list()
  .k <- 1L
  
  for (i in seq_along(.txt)) {
    .m <- gregexpr(.pat, .txt[i], perl = TRUE)
    .hits <- regmatches(.txt[i], .m)[[1]]
    if (length(.hits) == 0 || identical(.hits, character(0))) next
    
    for (.hit in .hits) {
      .parts <- regmatches(.hit, regexec(.pat, .hit, perl = TRUE))[[1]]
      if (length(.parts) != 3) next
      
      .var <- .parts[2]
      .lab <- .parts[3]
      .norm <- .normCategoryLabel(.lab)
      .ind <- paste0(.var, "_", .norm)
      
      .res[[.k]] <- data.frame(
        variable = .var,
        label = .lab,
        normalized = .norm,
        indicator = .ind,
        stringsAsFactors = FALSE
      )
      .k <- .k + 1L
    }
  }
  
  if (length(.res) == 0) {
    return(data.frame(
      variable = character(0),
      label = character(0),
      normalized = character(0),
      indicator = character(0),
      stringsAsFactors = FALSE
    ))
  }
  
  .df <- do.call(rbind, .res)
  .df[!duplicated(.df), , drop = FALSE]
}

.rewriteStringComparisonsToIndicators <- function(exprs, pred_var = "p1") {
  .map <- .extractStringComparisons(exprs)
  .txt <- vapply(exprs, deparse1, character(1))
  
  if (nrow(.map) > 0) {
    for (i in seq_along(.txt)) {
      for (j in seq_len(nrow(.map))) {
        .labEsc <- gsub("([][{}()+*^$.|\\\\?])", "\\\\\\1", .map$label[j])
        
        .pat1 <- paste0(
          "\\(\\s*", .map$variable[j], "\\s*==\\s*['\"]",
          .labEsc, "['\"]\\s*\\)"
        )
        .pat2 <- paste0(
          .map$variable[j], "\\s*==\\s*['\"]",
          .labEsc, "['\"]"
        )
        
        .txt[i] <- gsub(.pat1, .map$indicator[j], .txt[i], perl = TRUE)
        .txt[i] <- gsub(.pat2, .map$indicator[j], .txt[i], perl = TRUE)
      }
    }
  }
  
  .txt <- .txt[!grepl("~\\s*binom\\(", .txt)]
  .txt <- c(.txt, paste0("rx_pred_ <- ", pred_var))
  
  list(
    model = rxode2::rxode2(paste(.txt, collapse = "\n")),
    map = .map,
    lines = .txt
  )
}

.prepareCategoricalSolveData <- function(data, exprs,
                                         id_col = "ID",
                                         time_col = "TIME",
                                         dv_col = "DV") {
  .map <- .extractStringComparisons(exprs)
  
  dat <- data %>%
    dplyr::mutate(
      .id = .data[[id_col]],
      .time = .data[[time_col]],
      .dv = .data[[dv_col]]
    ) %>%
    dplyr::arrange(.id, .time)
  
  if (nrow(.map) > 0) {
    for (j in seq_len(nrow(.map))) {
      .var <- .map$variable[j]
      .ind <- .map$indicator[j]
      .lab <- .map$normalized[j]
      
      if (!(.var %in% names(dat))) {
        stop("Required categorical variable missing from data: ", .var)
      }
      
      dat[[.ind]] <- as.numeric(.normCategoryLabel(dat[[.var]]) == .lab)
      dat[[.ind]][is.na(dat[[.ind]])] <- 0
    }
  }
  
  list(data = dat, map = .map)
}

.getFixedEffectsFromFit <- function(fit) {
  if (!is.null(fit$parFixedDf)) {
    .df <- as.data.frame(fit$parFixedDf)
    .nm <- rownames(.df)
    .est_col <- intersect(c("Est.", "Estimate", "est"), names(.df))
    if (length(.est_col) == 0) {
      stop("Could not find fixed-effect estimate column in fit$parFixedDf")
    }
    .fx <- .df[[.est_col[1]]]
    names(.fx) <- .nm
    return(.fx)
  }
  
  if (!is.null(fit$parFixed) && is.numeric(fit$parFixed) && !is.null(names(fit$parFixed))) {
    return(fit$parFixed)
  }
  
  stop("Could not extract fixed effects from fit")
}

.buildCategoricalSimParams <- function(fit, ids) {
  fx <- .getFixedEffectsFromFit(fit)
  omega_mat <- as.matrix(fit$omega)
  
  if (is.null(rownames(omega_mat))) {
    stop("Omega matrix row names are required")
  }
  
  eta_draw <- MASS::mvrnorm(
    n = length(ids),
    mu = rep(0, nrow(omega_mat)),
    Sigma = omega_mat
  )
  
  eta_draw <- as.data.frame(eta_draw)
  names(eta_draw) <- rownames(omega_mat)
  
  sim_params <- data.frame(id = ids)
  for (.nm in names(fx)) {
    sim_params[[.nm]] <- rep(unname(fx[.nm]), length(ids))
  }
  for (.nm in names(eta_draw)) {
    sim_params[[.nm]] <- eta_draw[[.nm]]
  }
  
  sim_params
}


plot_categorical_vpc_nlmixr2 <- function(fit,
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
                                         title = "Categorical VPC") {
  set.seed(seed)
  
  req <- c(id_col, time_col, dv_col)
  miss <- setdiff(req, names(data))
  if (length(miss) > 0) {
    stop("Missing required columns in data: ", paste(miss, collapse = ", "))
  }
  
  ui <- rxode2::rxUiDecompress(fit)
  exprs <- ui$lstExpr
  
  pred_info <- .rewriteStringComparisonsToIndicators(exprs, pred_var = pred_var)
  pred_model <- pred_info$model
  
  prep <- .prepareCategoricalSolveData(
    data = data,
    exprs = exprs,
    id_col = id_col,
    time_col = time_col,
    dv_col = dv_col
  )
  
  dat <- prep$data %>%
    dplyr::mutate(
      id = as.integer(as.factor(.id)),
      time = .time,
      DV = .dv,
      time_plot = x_transform(.time)
    )
  
  needed_from_data <- pred_model$params[pred_model$params %in% names(dat)]
  solve_data <- dat %>%
    dplyr::select(dplyr::all_of(unique(c("id", "time", "DV", needed_from_data))))
  
  ids <- sort(unique(solve_data$id))
  
  fx <- .getFixedEffectsFromFit(fit)
  omega_mat <- as.matrix(fit$omega)
  eta_names <- rownames(omega_mat)
  
  if (is.null(eta_names)) {
    stop("Omega matrix row names are required")
  }
  
  t_range <- range(solve_data$time, na.rm = TRUE)
  t_range_plot <- range(dat$time_plot, na.rm = TRUE)
  breaks <- seq(t_range_plot[1], t_range_plot[2], length.out = nBins + 1)
  
  emp_dat <- dat %>%
    dplyr::transmute(
      time_plot = time_plot,
      DV = DV,
      timeBin = cut(time_plot, breaks = breaks, include.lowest = TRUE)
    )
  
  emp_mid <- emp_dat %>%
    dplyr::group_by(timeBin) %>%
    dplyr::summarise(timeMid = stats::median(time_plot, na.rm = TRUE), .groups = "drop")
  
  emp_prob <- emp_dat %>%
    dplyr::group_by(timeBin) %>%
    dplyr::summarise(
      empirical = mean(DV, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::left_join(emp_mid, by = "timeBin")
  
  sim_res <- do.call(rbind, lapply(seq_len(nSim), function(s) {
    eta_draw <- MASS::mvrnorm(
      n = length(ids),
      mu = rep(0, length(eta_names)),
      Sigma = omega_mat
    )
    
    if (is.null(dim(eta_draw))) {
      eta_draw <- matrix(eta_draw, ncol = length(eta_names))
    }
    
    eta_draw <- as.data.frame(eta_draw)
    names(eta_draw) <- eta_names
    
    sim_params <- data.frame(id = ids)
    for (.nm in names(fx)) {
      if (.nm == "n") next
      sim_params[[.nm]] <- rep(unname(fx[.nm]), length(ids))
    }
    for (.nm in eta_names) {
      sim_params[[.nm]] <- eta_draw[[.nm]]
    }
    
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
    
    sim_df <- data.frame(
      time = sim_solve$time,
      pred = sim_solve$rx_pred_
    ) %>%
      dplyr::mutate(
        time_plot = x_transform(time),
        simDV = stats::rbinom(
          n = dplyr::n(),
          size = 1,
          prob = pmin(pmax(pred, 1e-10), 1 - 1e-10)
        ),
        timeBin = cut(time_plot, breaks = breaks, include.lowest = TRUE)
      ) %>%
      dplyr::group_by(timeBin) %>%
      dplyr::summarise(
        simProp = mean(simDV),
        .groups = "drop"
      ) %>%
      dplyr::left_join(emp_mid, by = "timeBin") %>%
      dplyr::mutate(sim = s)
    
    sim_df
  }))
  
  alpha <- (1 - ci) / 2
  
  pi_df <- sim_res %>%
    dplyr::group_by(timeBin, timeMid) %>%
    dplyr::summarise(
      piLow = stats::quantile(simProp, probs = alpha, na.rm = TRUE),
      piMed = stats::quantile(simProp, probs = 0.5, na.rm = TRUE),
      piHigh = stats::quantile(simProp, probs = 1 - alpha, na.rm = TRUE),
      .groups = "drop"
    )
  
  plot_df <- emp_prob %>%
    dplyr::inner_join(pi_df, by = c("timeBin", "timeMid")) %>%
    dplyr::arrange(timeMid)
  
  pi_label <- paste0(ci * 100, "% Prediction interval")
  
  ggplot2::ggplot() +
    ggplot2::geom_ribbon(
      data = plot_df,
      ggplot2::aes(x = timeMid, ymin = piLow, ymax = piHigh, fill = pi_label),
      alpha = 0.35
    ) +
    ggplot2::geom_line(
      data = plot_df,
      ggplot2::aes(x = timeMid, y = empirical,
                   color = "Empirical probability",
                   linetype = "Empirical probability"),
      linewidth = 1
    ) +
    ggplot2::geom_line(
      data = plot_df,
      ggplot2::aes(x = timeMid, y = piMed,
                   color = "Predicted median",
                   linetype = "Predicted median"),
      linewidth = 0.9
    ) +
    ggplot2::scale_fill_manual(
      name = NULL,
      values = stats::setNames("#6BAED6", pi_label)
    ) +
    ggplot2::scale_color_manual(
      name = NULL,
      values = c(
        "Empirical probability" = "#08519C",
        "Predicted median" = "black"
      )
    ) +
    ggplot2::scale_linetype_manual(
      name = NULL,
      values = c(
        "Empirical probability" = "solid",
        "Predicted median" = "dashed"
      )
    ) +
    ggplot2::scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    ggplot2::labs(
      x = xlab,
      y = ylab,
      title = title
    ) +
    ggplot2::theme_bw(base_size = 13) +
    ggplot2::theme(
      legend.position = "bottom",
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(hjust = 0.5)
    )
}
