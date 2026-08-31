#' Plot a Pacific-centred base map
#'
#' Draws the world coastline using `ggplot2::map_data("world2")`
#'
#' @return A `ggplot` object.
#' @export
plot_pacific <- function(
  xlim = c(100, 292),
  ylim = c(-62, 60),
  land_fill = mapping_colours("land"),
  land_outline = mapping_colours("land_outline"),
  water_fill = mapping_colours("water"),
  base_size = 15,
  show_eez = FALSE
) {
  # in case the lims are overwritten by NULL elsewhere
  xlim <- xlim %||% c(100, 292)
  ylim <- ylim %||% c(-62, 60)

  p <-
    ggplot2::map_data("world2") |>
    ggplot2::ggplot(ggplot2::aes(long, lat, group = group)) +
    ggplot2::geom_polygon(
      fill = land_fill,
      colour = land_outline,
      linewidth = 0.2
    ) +
    ggplot2::coord_quickmap(xlim = xlim, ylim = ylim, expand = FALSE) +
    ggplot2::scale_x_continuous(
      breaks = seq(
        floor(xlim[1] / 20) * 20,
        ceiling(xlim[2] / 20) * 20,
        by = 20
      ),
      labels = .lon_labels
    ) +
    ggplot2::scale_y_continuous(labels = .lat_labels) +
    ggplot2::theme_minimal(base_size) +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(
        fill = water_fill,
        colour = NA
      ),
      panel.border = ggplot2::element_rect(
        colour = "black",
        fill = NA,
        linewidth = 1
      ),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    ) +
    ggplot2::labs(x = NULL, y = NULL)

  if (show_eez) {
    eez <- .get_eez()

    suppressMessages(
      p <-
        p +
        ggplot2::geom_sf(
          data = eez,
          inherit.aes = FALSE,
          fill = NA,
          col = "blue"
        ) +
        ggplot2::coord_sf(
          xlim = p$coordinates$limits$x,
          ylim = p$coordinates$limits$y,
          expand = FALSE
        )
    )
  }
  return(p)
}

#' @noRd
.lon_labels <- function(x) {
  x <- ifelse(x > 180, x - 360, x)
  paste0(abs(x), ifelse(x < 0, "\u00b0W", ifelse(x > 0, "\u00b0E", "\u00b0")))
}

#' @noRd
.lat_labels <- function(y) {
  paste0(abs(y), ifelse(y < 0, "\u00b0S", ifelse(y > 0, "\u00b0N", "\u00b0")))
}
