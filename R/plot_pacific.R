#' Plot a Pacific-centred base map
#'
#' Draws the world coastline using the Pacific-centred `"world2"` map from
#' the `maps` package, optionally overlaid with Exclusive Economic Zone (EEZ)
#' boundaries.
#'
#' @param xlim Numeric vector of length 2. Longitude limits in degrees east,
#'   on a 0-360 scale (e.g. 180 is the antimeridian and 200 is 160°W).
#'   Defaults to `c(100, 292)`. If `NULL`, the default is used.
#' @param ylim Numeric vector of length 2. Latitude limits in degrees, with
#'   negative values south of the equator. Defaults to `c(-62, 60)`. If
#'   `NULL`, the default is used.
#' @param land_fill Fill colour for land polygons. Defaults to
#'   `mapping_colours("land")`.
#' @param land_outline Outline colour for land polygons. Defaults to
#'   `mapping_colours("land_outline")`.
#' @param water_fill Background colour for the panel, representing water.
#'   Defaults to `mapping_colours("water")`.
#' @param base_size Base font size in points, passed to
#'   [ggplot2::theme_minimal()]. Defaults to `15`.
#' @param show_eez Logical. If `TRUE`, EEZ boundaries are drawn beneath the
#'   land layer. Defaults to `FALSE`.
#' @param eez_flag Character vector of flag codes used to select which EEZs
#'   are drawn when `show_eez = TRUE`. If `NULL` (default), no flag filter is
#'   applied. Ignored when `show_eez = FALSE`.
#' @param eez_colour Colour of the EEZ boundary lines. Defaults to `"blue"`.
#'   Ignored when `show_eez = FALSE`.
#'
#' @return A `ggplot` object.
#'
#' @importFrom maps map
#' @export
plot_pacific <- function(
  xlim = c(100, 292),
  ylim = c(-62, 60),
  land_fill = mapping_colours("land"),
  land_outline = mapping_colours("land_outline"),
  water_fill = mapping_colours("water"),
  base_size = 15,
  show_eez = FALSE,
  eez_flag = NULL,
  eez_colour = "blue"
) {
  # in case the lims are overwritten by NULL elsewhere
  xlim <- xlim %||% c(100, 292)
  ylim <- ylim %||% c(-62, 60)

  p <-
    ggplot2::map_data("world2") |>
    ggplot2::ggplot() +
    ggplot2::geom_polygon(
      ggplot2::aes(x = .data$long, y = .data$lat, group = .data$group),
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
    eez <- .get_eez(flag = eez_flag)

    suppressMessages(
      p <-
        p +
        ggplot2::geom_sf(
          data = eez,
          inherit.aes = FALSE,
          fill = NA,
          col = eez_colour
        ) +
        ggplot2::geom_polygon(
          ggplot2::aes(x = .data$long, y = .data$lat, group = .data$group),
          fill = land_fill,
          colour = land_outline,
          linewidth = 0.2
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
