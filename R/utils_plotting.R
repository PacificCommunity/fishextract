.add_optional_facet <- function(plot, facet_by = NULL, facet_scales = "free") {
  if (is.null(facet_by)) {
    return(plot)
  }

  facet_lookup <- label_lookup(facet_by)

  plot +
    ggplot2::facet_wrap(
      facet_by,
      scales = facet_scales,
      labeller = if (is.null(facet_lookup)) {
        ggplot2::label_value
      } else {
        ggplot2::as_labeller(facet_lookup)
      }
    )
}

#' @importFrom rlang .data
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
  if (is.null(breaks)) {
    max_total <- pie_data |>
      dplyr::summarise(
        total_catch = sum(.data$sum_catch_mt),
        .by = dplyr::all_of(setdiff(group_vars, colour_var))
      ) |>
      dplyr::pull(.data$total_catch) |>
      max()

    breaks <- scales::extended_breaks(n = 3)(c(0, max_total))
    breaks <- breaks[breaks > 0]
  }

  legend_data <- tibble::tibble(catch = sort(breaks, decreasing = TRUE)) |>
    dplyr::mutate(
      r = sqrt(.data$catch) / 150 * pie_radius,
      x0 = x0,
      y_centre = y0 + .data$r,
      y_top = y0 + 2 * .data$r,
      x_lead = x0 + max(.data$r) + spacing
    )

  list(
    ggforce::geom_circle(
      ggplot2::aes(x0 = .data$x0, y0 = .data$y_centre, r = .data$r),
      data = legend_data,
      fill = "grey70",
      colour = "black",
      linewidth = 0.2,
      inherit.aes = FALSE
    ),
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data$x0,
        y = .data$y_top,
        xend = .data$x_lead,
        yend = .data$y_top
      ),
      data = legend_data,
      linewidth = 0.2,
      inherit.aes = FALSE
    ),
    ggplot2::geom_text(
      ggplot2::aes(
        x = .data$x_lead + 0.5,
        y = .data$y_top,
        label = scales::comma(.data$catch)
      ),
      data = legend_data,
      hjust = 0,
      size = 3,
      inherit.aes = FALSE
    )
  )
}


add_line <- function(
  plot,
  type,
  x_position,
  y_position,
  colour = "red",
  linewidth = 0.8,
  linetype = "solid"
) {
  layer <-
    ggplot2::geom_path(
      data = .mapping_lines(type),
      ggplot2::aes(x = .data$x, y = .data$y),
      colour = colour,
      linewidth = linewidth,
      linetype = linetype,
      inherit.aes = FALSE
    )

  plot$layers <- append(plot$layers, list(layer), after = 0)

  plot
}

add_text <- function(
  plot,
  type,
  colour = "red",
  size = 5,
  ...
) {
  text <- .mapping_text(type)

  plot +
    ggplot2::geom_text(
      data = text,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
      colour = colour,
      size = size,
      inherit.aes = FALSE,
      ...
    )
}
