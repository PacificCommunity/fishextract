#' Plot a timeseries from a given data extract
#'
#' Sums a value column by year (`YY`) and, optionally, by a colouring and/or
#' faceting variable, then draws the result as a line-and-point plot. Colours
#' and facet labels are looked up from the package's internal lookups where
#' available.
#'
#' @param data A tibble extracted from one of the `fishextract::get_*`
#'   functions. Must contain a `YY` column (year) and the column to be
#'   plotted.
#' @param value_col <[`data-masking`][rlang::args_data_masking]> Column to sum
#'   and plot on the y-axis, supplied unquoted. If `NULL` (default), it is
#'   detected from `data`: `sum_catch_mt` if present, otherwise `n_vessels`.
#'   An error is raised if neither is found.
#' @param colour_by <[`data-masking`][rlang::args_data_masking]> Optional
#'   column to group and colour the timeseries by, supplied unquoted. If
#'   `NULL` (default), a single series is drawn.
#' @param facet_by <[`data-masking`][rlang::args_data_masking]> Optional
#'   column to split the plot into facets by, supplied unquoted. If `NULL`
#'   (default), no faceting is applied.
#' @param facet_scales Character string passed to [ggplot2::facet_wrap()].
#'   One of `"fixed"` (default), `"free"`, `"free_x"` or `"free_y"`. Ignored
#'   when `facet_by = NULL`.
#' @param y_lab Character string for the y-axis label. If `NULL` (default),
#'   `"Catch (mt)"` or `"Number of vessels"` is used when `value_col` is
#'   detected automatically, otherwise the name of `value_col`.
#' @param n_breaks Integer. Approximate number of x-axis (year) breaks, passed
#'   to [base::pretty()]. Defaults to `5`.
#'
#' @return A `ggplot` object.
#'
#' @export
plot_timeseries <- function(
  data,
  value_col = NULL,
  colour_by = NULL,
  facet_by = NULL,
  facet_scales = "fixed",
  y_lab = NULL,
  n_breaks = 5
) {
  if (is.null(value_col)) {
    defaults <- switch(
      intersect(c("sum_catch_mt", "n_vessels"), names(data))[1],

      sum_catch_mt = list(
        value_col = rlang::sym("sum_catch_mt"),
        y_lab = "Catch (mt)"
      ),

      n_vessels = list(
        value_col = rlang::sym("n_vessels"),
        y_lab = "Number of vessels"
      ),

      rlang::abort(
        "Could not determine a default value column. Supply `value_col` explicitly."
      )
    )

    value_col <- defaults$value_col
    y_lab <- y_lab %||% defaults$y_lab
  } else {
    value_col <- rlang::ensym(value_col)
    y_lab <- y_lab %||% rlang::as_name(value_col)
  }

  colour_by <- rlang::enquo(colour_by)
  facet_by <- rlang::enquo(facet_by)
  colour_values <- if (!rlang::quo_is_null(colour_by)) {
    lookup_colour(rlang::as_name(colour_by))
  } else {
    NULL
  }

  group_vars <- c(
    "YY",
    if (!rlang::quo_is_null(colour_by)) rlang::as_name(colour_by),
    if (!rlang::quo_is_null(facet_by)) rlang::as_name(facet_by)
  )

  plot_data <-
    data |>
    dplyr::summarise(
      y_variable = sum(!!value_col),
      .by = dplyr::all_of(group_vars)
    )

  integer_breaks <- function(n = n_breaks, ...) {
    fxn <- function(x) {
      breaks <- floor(pretty(x, n, ...))
      names(breaks) <- attr(breaks, "labels")
      breaks
    }
    return(fxn)
  }

  p <-
    ggplot2::ggplot(
      plot_data,
      ggplot2::aes(
        x = .data$YY,
        y = .data$y_variable,
        colour = !!colour_by,
        group = !!colour_by
      )
    ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point() +
    ggplot2::labs(x = NULL, y = y_lab, colour = NULL) +
    ggplot2::scale_y_continuous(
      labels = scales::label_number(scale_cut = scales::cut_short_scale())
    ) +
    ggplot2::scale_x_continuous(breaks = integer_breaks(n = n_breaks)) +
    theme_fishextract()

  if (!rlang::quo_is_null(facet_by)) {
    facet_lookup <- label_lookup(rlang::as_name(facet_by))
    facet_labeller <- if (!is.null(facet_lookup)) {
      ggplot2::as_labeller(facet_lookup)
    } else {
      ggplot2::label_value
    }

    p <- p +
      ggplot2::facet_wrap(
        ggplot2::vars(!!facet_by),
        scales = facet_scales,
        labeller = facet_labeller
      )
  }

  if (!is.null(colour_values)) {
    colour_lookup <- label_lookup(rlang::as_name(colour_by))

    p <- p +
      ggplot2::scale_colour_manual(
        values = colour_values,
        labels = colour_lookup %||% ggplot2::waiver()
      )
  }

  return(p)
}
