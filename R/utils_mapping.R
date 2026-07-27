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

.plot_region_lines_lookup <- list(
  wcpfc = function(colour1 = "red", ...) {
    plot_pacific() |>
      add_line("wcpfc", colour = colour1) |>
      add_text("wcpfc", colour = colour1)
  },

  wcpo_epo = function(colour1 = "red", ...) {
    plot_pacific() |>
      add_line("meridian", colour = colour1) |>
      add_text("wcpo", colour = colour1) |>
      add_text("epo", colour = colour1)
  },

  npo_spo = function(colour1 = "red", ...) {
    plot_pacific() |>
      add_line("equator", colour = colour1) |>
      add_text("np", colour = colour1) |>
      add_text("sp", colour = colour1)
  },

  nx_sx = function(colour1 = "red", ...) {
    plot_pacific() |>
      add_line("wcpfc", colour = colour1) |>
      add_line("equator_wcpfc", colour = colour1) |>
      add_text("nx", colour = colour1) |>
      add_text("sx", colour = colour1)
  },

  wcpfc_epo = function(colour1 = "red", colour2 = "blue", ...) {
    plot_pacific() |>
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
lon_to_360 <- function(lon) {
  dplyr::if_else(lon < 0, lon + 360, lon)
}
