.add_optional_facet <- function(plot, facet_by = NULL, facet_scales = "free") {
  p <- plot

  if (!is.null(facet_by)) {
    facet_vals <- p$data[[facet_by]]

    facet_lookup <- pkg_label_lookup(facet_by)

    facet_labeller <- if (!is.null(facet_lookup)) {
      ggplot2::as_labeller(facet_lookup)
    } else {
      ggplot2::label_value
    }

    p <- p +
      ggplot2::facet_wrap(
        ggplot2::vars(.data[[facet_by]]),
        scales = facet_scales,
        labeller = facet_labeller
      )
  }

  p
}


.build_size_legend_geom <- function(
  pie_data,
  group_vars,
  colour_var, # plain string or NULL, not a quosure
  x0,
  y0,
  breaks = NULL,
  pie_radius = 1,
  spacing = 3
) {
  site_totals <- pie_data |>
    dplyr::summarise(
      total_catch = sum(sum_catch_mt),
      .by = setdiff(group_vars, colour_var)
    )

  if (is.null(breaks)) {
    breaks <- scales::extended_breaks(n = 3)(c(0, max(site_totals$total_catch)))
    breaks <- breaks[breaks > 0]
  }

  legend_data <-
    tibble::tibble(catch = sort(breaks, decreasing = TRUE)) |>
    dplyr::mutate(
      r = sqrt(catch) / 150 * pie_radius,
      x0 = x0,
      y0 = y0 + r,
      y_top = y0 + r,
      x_lead = x0 + max(r) + spacing
    )

  list(
    ggforce::geom_circle(
      ggplot2::aes(x0 = x0, y0 = y0, r = r),
      data = legend_data,
      fill = "grey70",
      colour = "black",
      linewidth = 0.2,
      inherit.aes = FALSE
    ),
    ggplot2::geom_segment(
      ggplot2::aes(x = x0, y = y_top, xend = x_lead, yend = y_top),
      data = legend_data,
      linewidth = 0.2,
      inherit.aes = FALSE
    ),
    ggplot2::geom_text(
      ggplot2::aes(x = x_lead + 0.5, y = y_top, label = scales::comma(catch)),
      data = legend_data,
      hjust = 0,
      size = 3,
      inherit.aes = FALSE
    )
  )
}
