.mapping_lines_lookup <- list(
  wcpfc = data.frame(
    x = c(124, 130, 130, 141, 141, 150, 150, 230, 230, 210, 210),
    y = c(-10, -10, -30, -30, -55, -55, -60, -60, -4, -4, 60)
  ),
  equator = data.frame(
    x = c(100, 292),
    y = c(0, 0)
  ),
  equator_wcpfc = data.frame(
    x = c(100, 210),
    y = c(0, 0)
  ),
  meridian = data.frame(
    x = c(210, 210),
    y = c(-62, 60)
  ),
  meridian_wcpfc = data.frame(
    x = c(210, 210),
    y = c(-60, 60)
  )
)

#' Common text locations for maps
#' @keywords internal
.mapping_text_lookup <- list(
  wcpfc = data.frame(
    x = 160,
    y = 10,
    label = "Western and Central Pacific Fisheries\n Commission Convention Area\n (WCPFC-CA)"
  ),
  nx = data.frame(
    x = 160,
    y = 25,
    label = "WCPFC-CA:\n North of the equator"
  ),
  sx = data.frame(
    x = 180,
    y = -25,
    label = "WCPFC-CA:\n South of the equator"
  ),
  np = data.frame(
    x = 180,
    y = 30,
    label = "North Pacific Ocean"
  ),
  sp = data.frame(
    x = 200,
    y = -30,
    label = "South Pacific Ocean"
  ),
  wcpo = data.frame(
    x = 160,
    y = 10,
    label = "Western and Central\n Pacific Ocean (WCPO)"
  ),
  epo = data.frame(
    x = 245,
    y = 0,
    label = "Eastern Pacific Ocean\n (WCPO)"
  )
)

.mapping_text <- function(type) {
  .mapping_text_lookup[[type]] %||%
    stop("Unknown text type: ", type, call. = FALSE)
}

.mapping_lines <- function(type) {
  .mapping_lines_lookup[[type]] %||%
    stop("Unknown text type: ", type, call. = FALSE)
}

# ---- Shading polygons ----------------------------------------------------

.map_xlim <- c(100, 292)
.map_ylim <- c(-62, 60)

.close_ring <- function(df) {
  rbind(as.matrix(df[c("x", "y")]), as.matrix(df[1, c("x", "y")]))
}
.to_sf_polygon <- function(df) sf::st_polygon(list(.close_ring(df)))

.rect_polygon <- function(xmin, xmax, ymin, ymax) {
  .to_sf_polygon(data.frame(
    x = c(xmin, xmax, xmax, xmin),
    y = c(ymin, ymin, ymax, ymax)
  ))
}

# WCPFC-CA: stepped boundary line, closed to the map's NW edge, with a
# CRUDE line following the Indonesian boundary (need to make sure we state that this is for visual purposes only)
.wcpfc_polygon <- dplyr::bind_rows(
  .mapping_lines_lookup$wcpfc,
  data.frame(
    x = c(.map_xlim[1], 100, 108, 115),
    y = c(.map_ylim[2], 0, -8, -8)
  )
) |>
  .to_sf_polygon()

#' Closed polygons for shaded map regions, keyed to match `.mapping_text_lookup`
#' @keywords internal
.mapping_polygons_lookup <- list(
  wcpfc = .wcpfc_polygon,
  wcpo = .rect_polygon(.map_xlim[1], 210, .map_ylim[1], .map_ylim[2]),
  epo = .rect_polygon(210, .map_xlim[2], .map_ylim[1], .map_ylim[2]),
  np = .rect_polygon(.map_xlim[1], .map_xlim[2], 0, .map_ylim[2]),
  sp = .rect_polygon(.map_xlim[1], .map_xlim[2], .map_ylim[1], 0)
)
.mapping_polygons_lookup$nx <- sf::st_intersection(
  .mapping_polygons_lookup$wcpfc,
  .mapping_polygons_lookup$np
)
.mapping_polygons_lookup$sx <- sf::st_intersection(
  .mapping_polygons_lookup$wcpfc,
  .mapping_polygons_lookup$sp
)

#' Add shaded region(s) to a Pacific map
#'
#' Shades the area of one or more named regions (see `.mapping_polygons_lookup`).
#' When `type` has length > 1, their union is shaded as a single polygon —
#' use this for regions that share a colour (e.g. `c("nx", "sx")`).
#'
#' @param plot A ggplot object, as built by `plot_pacific()`.
#' @param type Character vector of region name(s) to shade.
#' @param fill Fill colour.
#' @param alpha Fill transparency.
#' @keywords internal
add_shading <- function(plot, type, fill = "red", alpha = 0.2) {
  polys <- .mapping_polygons_lookup[type]
  missing_types <- type[vapply(polys, is.null, logical(1))]
  if (length(missing_types) > 0) {
    stop(
      "Unknown shading type(s): ",
      paste(missing_types, collapse = ", "),
      call. = FALSE
    )
  }

  region <- if (length(polys) > 1) {
    sf::st_union(sf::st_sfc(polys))
  } else {
    polys[[1]]
  }
  coords <- as.data.frame(sf::st_coordinates(region))[c("X", "Y")]

  shading_layer <- ggplot2::geom_polygon(
    data = coords,
    mapping = ggplot2::aes(x = .data$X, y = .data$Y),
    fill = fill,
    alpha = alpha,
    colour = NA,
    inherit.aes = FALSE
  )
  # insert after the base land/water layer(s), below lines and text
  plot$layers <- append(plot$layers, shading_layer, after = 1)
  plot
}

# Which region(s) to shade per plot type, and which colour arg to use.
# Regions sharing a colour_arg are 'unioned' into one shaded polygon.
.plot_region_shading_lookup <- list(
  wcpfc = list(list(types = "wcpfc", colour_arg = "colour1")),
  wcpo_epo = list(
    list(types = "wcpo", colour_arg = "colour1"),
    list(types = "epo", colour_arg = "colour2")
  ),
  npo_spo = list(
    list(types = "np", colour_arg = "colour1"),
    list(types = "sp", colour_arg = "colour2")
  ),
  nx_sx = list(list(types = c("nx", "sx"), colour_arg = "colour1")),
  wcpfc_epo = list(
    list(types = "wcpfc", colour_arg = "colour1"),
    list(types = "epo", colour_arg = "colour2")
  )
)
.plot_region_lines_lookup <- list(
  wcpfc = function(plot, colour1 = "red", ...) {
    plot |>
      add_line("wcpfc", colour = colour1) |>
      add_text("wcpfc", colour = colour1)
  },

  wcpo_epo = function(plot, colour1 = "red", ...) {
    plot |>
      add_line("meridian", colour = colour1) |>
      add_text("wcpo", colour = colour1) |>
      add_text("epo", colour = colour1)
  },

  npo_spo = function(plot, colour1 = "red", ...) {
    plot |>
      add_line("equator", colour = colour1) |>
      add_text("np", colour = colour1) |>
      add_text("sp", colour = colour1)
  },

  nx_sx = function(plot, colour1 = "red", ...) {
    plot |>
      add_line("wcpfc", colour = colour1) |>
      add_line("equator_wcpfc", colour = colour1) |>
      add_text("nx", colour = colour1) |>
      add_text("sx", colour = colour1)
  },

  wcpfc_epo = function(plot, colour1 = "red", colour2 = "blue", ...) {
    plot |>
      add_line("wcpfc", linetype = "dashed", colour = colour1) |>
      add_line("meridian", colour = colour2) |>
      add_text("epo", colour = colour2) |>
      add_text("wcpfc", colour = colour1)
  }
)

#' Convert decimal longitude (-180 to 180) to 0-360 for Pacific-centred maps
#'
#' @param lon Numeric vector of longitudes in -180 to 180 format.
#' @return Numeric vector of longitudes in 0-360 format.
#' @export
lon_to_360 <- function(lon) lon %% 360
