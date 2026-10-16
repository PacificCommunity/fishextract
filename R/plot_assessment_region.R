#' Add Stock assessment region boundaries to a Pacific map
#'
#' @param bounding_box sf object either outputted from `get_md2_shp` or
#' @param linewidth Boundary line width. Defaults to `0.5`.
#' @param plot Optional ggplot object for the assessment regions to be plotted over
#' @param buffer Optional numeric. Buffer around outside of plotting area.
#' @param ... optional arguments to be passed to the `plot_pacific` function
#'
#' @return A ggplot object with region boundary polygons added.
#'
#' @examples
#'
#' plot_assessment_region(bounding_box = get_md2_shp(species ="YFT"))
#'
#' # custom region
#' areas <- tibble::tribble(
#'   ~region_id, ~lon, ~lat,
#'   "1",         110,  0,
#'   "1",         145,  0,
#'   "1",         145,  20,
#'   "1",         110,  20,
#'   "2",         160,  0,
#'   "2",         165,  -20,
#'   "2",         190,  -15
#' )
#'
#' plot_assessment_region(bounding_box = as_region(areas))
#'
#' @export
plot_assessment_region <- function(
  bounding_box,
  linewidth = 0.5,
  buffer = 0.05,
  plot = NULL,
  ...
) {
  assessment_region <- as_region(bounding_box)
  if (is.null(plot)) {
    plot <- plot_pacific(...)
  }

  region_bbox <- sf::st_bbox(assessment_region)
  coord <- plot$coordinates

  widen <- function(current, new, buffer = 0.05, always = FALSE) {
    new <- range(new)
    if (is.null(current)) {
      return(new + c(-1, 1) * buffer * diff(new))
    }
    original <- range(current)
    widened <- range(original, new)
    widened + c(-1, 1) * buffer * diff(widened) * (always | widened != original)
  }

  suppressMessages(
    plot +
      ggplot2::geom_sf(
        data = assessment_region,
        ggplot2::aes(colour = factor(.data$region_id)),
        fill = NA,
        linewidth = linewidth,
        inherit.aes = FALSE
      ) +
      ggplot2::coord_sf(
        xlim = widen(
          coord$limits$x,
          region_bbox[c("xmin", "xmax")],
          always = TRUE
        ),
        ylim = widen(
          coord$limits$y,
          region_bbox[c("ymin", "ymax")],
          always = TRUE
        ),
        expand = FALSE,
        crs = coord$crs,
        default_crs = coord$default_crs
      ) +
      ggplot2::labs(colour = "Region")
  )
}
