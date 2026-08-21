#' Create Pacific Ocean Region Maps
#'
#' Generates a predefined Pacific Ocean map with region boundaries and labels.
#' The map type is specified by `type`, with each type corresponding to a
#' particular combination of lines and text annotations.
#'
#' @param type Character string indicating the map to produce. One of:
#' \describe{
#'   \item{"wcpfc"}{Western and Central Pacific Fisheries Commission
#'   Convention Area.}
#'   \item{"wcpo_epo"}{Western-Central Pacific Ocean and Eastern Pacific Ocean
#'   split, separated by the 150°W meridian.}
#'   \item{"npo_spo"}{North Pacific Ocean and South Pacific Ocean split,
#'   separated by the equator.}
#'   \item{"nx_sx"}{Northern and Southern regions within the WCPFC Convention
#'   Area, separated by the equator west of the WCPFC boundary.}
#'   \item{"wcpfc_epo"}{Overlay of the WCPFC Convention Area and the WCPO/EPO
#'   split. Colours can be customised using `colour1` and `colour2`.}
#' }
#' @param colour1 Colour used for the first region in map types that support
#'   colour customisation. Defaults to `"red"`.
#' @param colour2 Colour used for the second region in map types that support
#'   colour customisation. Defaults to `"blue"`.
#' @param shading Logical. If `TRUE`, shade the region(s) relevant to `type`.
#'   Where a plot type shares one colour across multiple sub-regions (e.g.
#'   `"nx_sx"`), their union is shaded as a single area.
#' @param alpha Shading transparency. Defaults to `0.2`.
#'
#' @return
#' A ggplot object showing the requested Pacific Ocean region map.
#'
#' @examples
#' plot_region_lines("wcpfc")
#'
#' plot_region_lines("wcpo_epo")
#'
#' plot_region_lines("npo_spo")
#'
#' plot_region_lines("nx_sx")
#'
#' plot_region_lines("wcpfc_epo")
#'
#' # Custom colours
#' plot_region_lines("wcpfc_epo",
#'          colour1 = "darkorange",
#'          colour2 = "navy")
#'
#' # With shading
#' plot_region_lines("wcpfc", shading = TRUE)
#' plot_region_lines("nx_sx", colour1 = "darkgreen", shading = TRUE)
#'
#' @export
plot_region_lines <- function(
  type,
  colour1 = "red",
  colour2 = "blue",
  shading = FALSE,
  alpha = 0.2
) {
  fun <- .plot_region_lines_lookup[[type]]
  if (is.null(fun)) {
    stop(
      glue::glue(
        "Unknown plot type: '{type}'. Options include: 'wcpfc', 'wcpo_epo', 'npo_spo', 'nx_sx', 'wcpfc_epo'"
      ),
      call. = FALSE
    )
  }

  plot <- fun(colour1 = colour1, colour2 = colour2)

  if (shading) {
    for (grp in .plot_region_shading_lookup[[type]]) {
      colour <- if (grp$colour_arg == "colour1") colour1 else colour2
      plot <- add_shading(plot, grp$types, fill = colour, alpha = alpha)
    }
  }

  plot
}
