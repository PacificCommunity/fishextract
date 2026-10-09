#' Plot aggregated catch as scatterpies on a Pacific basemap
#'
#' Aggregates catch data by location (and optionally by colour and facet
#' variables), then plots each location as a pie chart ("scatterpie") whose
#' radius is proportional to total catch and whose wedges show the
#' proportional breakdown of `colour_by`. A size legend is added
#' automatically, and the plot can optionally be faceted.
#'
#' @param aggregated_data A data frame of catch data with, at minimum,
#'   `latd`, `lond` and `sum_catch_mt` columns.
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
#' @param lim_buffer Numeric. Buffer around the outermost data points. Defaults to `0.1`.
#' @param water_fill Character string. Fill colour of the water.
#'
#' @return A `ggplot` object.
#'
#' @examples
#'
#' agg_catch <- get_aggregated_catch(year = 2020:2023, species = c("YFT", "SKJ"))
#' plot_aggregated_catch(agg_catch)
#' plot_aggregated_catch(agg_catch, colour_by = SP_CODE, facet_by = year)
#'
#'
#' @export
plot_aggregated_catch <- function(
  aggregated_data,
  colour_by = NULL,
  facet_by = NULL,
  pie_radius = NULL,
  alpha = 1,
  xlim = NULL,
  ylim = NULL,
  lim_buffer = 0.1,
  water_fill = "white"
) {
  if (is.null(xlim) || is.null(ylim)) {
    lond_360_range <- range(lon_to_360(aggregated_data$lond), na.rm = TRUE)
    latd_range <- range(aggregated_data$latd, na.rm = TRUE)
    xlim <- xlim %||%
      (lond_360_range + c(-1, 1) * lim_buffer * diff(lond_360_range))
    ylim <- ylim %||% (latd_range + c(-1, 1) * lim_buffer * diff(latd_range))
  }

  # legend position
  x0 <- max(xlim) - 0.2 * diff(xlim)
  y0 <- min(ylim) + 0.05 * diff(ylim)

  facet_by <- rlang::enquo(facet_by)
  colour_by <- rlang::enquo(colour_by)
  has_colour <- !rlang::quo_is_null(colour_by)
  colour_var <- if (has_colour) rlang::as_name(colour_by) else NULL
  facet_var <- if (!rlang::quo_is_null(facet_by)) {
    rlang::as_name(facet_by)
  } else {
    NULL
  }

  # calculate the lat-offset
  unique_lats <- sort(unique(aggregated_data$latd))
  latlon_gaps <- min(unique_lats - dplyr::lag(unique_lats, 1), na.rm = TRUE)
  latlon_offset <- latlon_gaps / 2

  fill_values <- if (has_colour) lookup_colour(colour_var) else NULL
  fill_labels <- if (has_colour) label_lookup(colour_var) else NULL

  group_vars <- c(
    "latd",
    "lond",
    if (has_colour) colour_var,
    if (!is.null(facet_var)) facet_var
  )

  pie_data <-
    aggregated_data |>
    dplyr::summarise(
      sum_catch_mt = sum(.data$sum_catch_mt),
      .by = dplyr::all_of(group_vars)
    ) |>
    dplyr::mutate(lond_360 = lon_to_360(.data$lond)) |>
    dplyr::mutate(
      total_catch_mt = sum(.data$sum_catch_mt),
      r = sqrt(.data$total_catch_mt) / 150,
      prop = .data$sum_catch_mt / .data$total_catch_mt,
      end = cumsum(.data$prop) * 2 * pi,
      start = dplyr::lag(.data$end, default = 0),
      .by = setdiff(group_vars, colour_var)
    )

  # auto calculate the pie radius if it isn't provided (is NULl)
  if (is.null(pie_radius)) {
    target_r <- 0.04 * min(diff(xlim), diff(ylim))
    pie_radius <- target_r / max(pie_data$r, na.rm = TRUE)
  }

  p <- plot_pacific(xlim = xlim, ylim = ylim, water_fill = water_fill)

  if (has_colour) {
    p <-
      p +
      ggforce::geom_arc_bar(
        mapping = ggplot2::aes(
          x0 = .data$lond_360 + latlon_offset,
          y0 = .data$latd + latlon_offset,
          r0 = 0,
          r = .data$r * pie_radius,
          start = .data$start,
          end = .data$end,
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
  } else {
    # if no colour is suggested then we can do tile plot rather than the pie chart
    # (which i think is a little ugly anyway)
    rect_layer <-
      ggplot2::geom_raster(
        mapping = ggplot2::aes(
          x = .data$lond_360 + latlon_offset,
          y = .data$latd + latlon_offset,
          fill = .data$total_catch_mt
        ),
        data = pie_data,
        inherit.aes = FALSE
      )

    p$layers <- append(p$layers, list(rect_layer), after = 0)

    p <-
      p +
      ggplot2::scale_fill_viridis_c(
        name = "Total catch (mt)",
        labels = scales::label_number(
          scale_cut = scales::cut_short_scale(),
          trans = "log"
        )
      )
  }

  if (has_colour && !is.null(fill_values)) {
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
