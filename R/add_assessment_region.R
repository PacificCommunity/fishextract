#' Add Stock assessment region boundaries to a Pacific map
#'
#' Queries region boundary polygons for a given model from the MD2 database
#' and layers them onto an existing Pacific map (typically from
#' `plot_pacific()`), coloured by `region_id`.
#'
#' @param plot A ggplot object to add region boundaries to, as built by
#'   `plot_pacific()`.
#' @param model_id Integer. The `model_id` to filter region boundaries by.
#' @param linewidth Boundary line width. Defaults to `0.5`.
#'
#' @return A ggplot object with region boundary polygons added.
#'
#' @examples
#' plot_pacific() |> add_assessment_region(model_id = 129)
#'
#' @export
add_assessment_region <- function(plot, model_id, linewidth = 0.5) {
  xx <-
    db_query(
      server = "noufamesql01",
      database = "md2",
      query = glue::glue(
        "SELECT
          r.region_id,
          r.bounding_box_id,
          CAST(b.geom.STAsText() AS VARCHAR(8000)) as geometry,
          b.model_id
        FROM md2.app.region_bounding_box r
        JOIN md2.app.region b ON r.region_id = b.region_id
        WHERE b.model_id = {model_id}"
      )
    ) |>
    sf::st_as_sf(wkt = "geometry", crs = 4326) |>
    sf::st_shift_longitude() # -180/180 -> 0/360, to match plot_pacific()'s world2 basemap

  plot +
    ggplot2::geom_sf(
      data = xx,
      ggplot2::aes(colour = factor(region_id)),
      fill = NA,
      linewidth = linewidth,
      inherit.aes = FALSE
    ) +
    ggplot2::coord_sf(
      xlim = plot$coordinates$limits$x,
      ylim = plot$coordinates$limits$y,
      expand = FALSE
    ) +
    ggplot2::labs(colour = "Region")
}
