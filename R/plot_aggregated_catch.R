plot_aggregated_catch <- function(
  aggregated_data = NULL,
  colour_by = SP_CODE,
  facet_by = NULL,
  pie_radius = 1,
  alpha = 1,
  xlim = NULL,
  ylim = NULL,
  ...
) {
  # use the default values if NULL
  xlim <- xlim %||% c(100, 292)
  ylim <- ylim %||% c(-62, 60)
  # for the legend position
  x0 <- max(xlim) - 0.2 * diff(xlim)
  y0 <- min(ylim) + 0.05 * diff(ylim)

  if (is.null(aggregated_data)) {
    aggregated_data <- get_logbook_coverage(...)
  }

  facet_by <- rlang::enquo(facet_by)
  colour_by <- rlang::enquo(colour_by)
  colour_var <- if (!rlang::quo_is_null(colour_by)) {
    rlang::as_name(colour_by)
  } else {
    NULL
  }
  facet_var <- if (!rlang::quo_is_null(facet_by)) {
    rlang::as_name(facet_by)
  } else {
    NULL
  }

  fill_values <- if (!is.null(colour_var)) {
    pkg_colour_lookup(colour_var)
  } else {
    NULL
  }
  fill_labels <- if (!is.null(colour_var)) {
    pkg_label_lookup(colour_var)
  } else {
    NULL
  }

  group_vars <- c(
    "latd",
    "lond",
    if (!rlang::quo_is_null(colour_by)) rlang::as_name(colour_by),
    if (!rlang::quo_is_null(facet_by)) rlang::as_name(facet_by)
  )

  pie_data <-
    aggregated_data |>
    dplyr::summarise(
      sum_catch_mt = sum(sum_catch_mt),
      .by = dplyr::all_of(group_vars)
    ) |>
    dplyr::mutate(lond_360 = lon_to_360(lond)) |>
    dplyr::mutate(lond_360 = lond_360, latd = latd) |>
    dplyr::mutate(
      r = sqrt(sum(sum_catch_mt)) / 150,
      .by = setdiff(group_vars, rlang::as_name(colour_by))
    ) |>
    dplyr::mutate(
      prop = sum_catch_mt / sum(sum_catch_mt),
      end = cumsum(prop) * 2 * pi,
      start = dplyr::lag(end, default = 0),
      .by = setdiff(group_vars, rlang::as_name(colour_by))
    )

  p <-
    plot_pacific(xlim = xlim, ylim = ylim) +
    ggforce::geom_arc_bar(
      mapping = ggplot2::aes(
        x0 = lond_360 + 2.5,
        y0 = latd + 2.5,
        r0 = 0,
        r = r * pie_radius,
        start = start,
        end = end,
        fill = !!colour_by
      ),
      data = pie_data,
      colour = "black",
      linewidth = 0.2,
      alpha = alpha,
      inherit.aes = FALSE
    ) +
    .build_size_legend_geom(
      pie_data,
      group_vars,
      colour_by = colour_by,
      x0 = x0,
      y0 = y0,
      breaks = NULL,
      pie_radius = pie_radius
    ) +
    ggplot2::labs(fill = NULL)

  if (!is.null(fill_values)) {
    p <-
      p +
      ggplot2::scale_fill_manual(
        values = fill_values,
        labels = fill_labels %||% ggplot2::waiver()
      )
  }

  p <-
    p |>
    .add_optional_facet(
      facet_by = facet_var,
      facet_scales = "fixed"
    )

  return(p)
}
