#' Plot aggregated catch as scatterpies on a Pacific basemap
#'
#' Aggregates catch data by location (and optionally by colour and facet
#' variables), then plots each location as a pie chart ("scatterpie") whose
#' radius is proportional to total catch and whose wedges show the
#' proportional breakdown of `colour_by`. A size legend is added
#' automatically, and the plot can optionally be faceted.
#'
#' @param aggregated_data A data frame of catch data with, at minimum,
#'   `latd`, `lond` and `sum_catch_mt` columns. If `NULL` (the default),
#'   data are pulled via [get_logbook_coverage()], with `...` passed through.
#' @param colour_by <[`data-masked`][rlang::args_data_masking]> Column used
#'   to fill and split each pie into wedges (e.g. species code). Set to
#'   `NULL` to omit colour splitting and plot single-colour pies.
#' @param facet_by <[`data-masked`][rlang::args_data_masking]> Optional
#'   column to facet the plot by (e.g. year, gear type). Defaults to `NULL`
#'   (no faceting).
#' @param pie_radius Numeric scalar; multiplier applied to pie and legend
#'   circle radii. Defaults to `1`.
#' @param alpha Numeric scalar; fill transparency for the pie wedges.
#'   Defaults to `1`.
#' @param xlim Numeric vector of length 2 giving longitude limits (0--360
#'   convention). Defaults to `c(100, 292)`.
#' @param ylim Numeric vector of length 2 giving latitude limits. Defaults
#'   to `c(-62, 60)`.
#' @param ... Additional arguments passed to [get_logbook_coverage()] when
#'   `aggregated_data` is `NULL`.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' plot_aggregated_catch(catch_data, colour_by = SP_CODE)
#' plot_aggregated_catch(catch_data, colour_by = SP_CODE, facet_by = yy)
#' plot_aggregated_catch(colour_by = SP_CODE, yy = 2020:2023)
#' }
#'
#' @export
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
    dplyr::mutate(
      total_catch_mt = sum(sum_catch_mt),
      r = sqrt(total_catch_mt) / 150,
      prop = sum_catch_mt / total_catch_mt,
      end = cumsum(prop) * 2 * pi,
      start = dplyr::lag(end, default = 0),
      .by = setdiff(group_vars, colour_var)
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
      colour_var = colour_var,
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
