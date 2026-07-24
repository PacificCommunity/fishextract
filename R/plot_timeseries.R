plot_timeseries <- function(
  data,
  value_col = NULL,
  colour_by = NULL,
  facet_by = NULL,
  facet_scales = "fixed",
  y_lab = NULL
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
    pkg_colour_lookup(rlang::as_name(colour_by))
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

  p <-
    ggplot2::ggplot(
      plot_data,
      ggplot2::aes(
        x = YY,
        y = y_variable,
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
    theme_fishextract()

  if (!rlang::quo_is_null(facet_by)) {
    facet_lookup <- pkg_label_lookup(rlang::as_name(facet_by))
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
    colour_lookup <- pkg_label_lookup(rlang::as_name(colour_by))

    p <- p +
      ggplot2::scale_colour_manual(
        values = colour_values,
        labels = colour_lookup %||% ggplot2::waiver()
      )
  }

  return(p)
}
