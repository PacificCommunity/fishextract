#' Add Stock assessment region boundaries to a Pacific map
#'
#' Queries region boundary polygons for a given model from the MD2 database
#' and layers them onto an existing Pacific map (typically from
#' `plot_pacific()`), coloured by `region_id`.
#'
#' @param plot A ggplot object to add region boundaries to, as built by
#'   `plot_pacific()`.
#' @param species Single character string indicating the species for which the models regions are to be plotted.
#' @param linewidth Boundary line width. Defaults to `0.5`.
#'
#' @return A ggplot object with region boundary polygons added.
#'
#' @examples
#' plot_pacific() |> add_assessment_region(species = "YFT")
#'
#' @export
add_assessment_region <- function(
  plot,
  # bounding_box,
  species = c("YFT", "SKJ", "ALB", "BET"),
  linewidth = 0.5
) {
  verified_species <- rlang::arg_match(species)
  model_id <- switch(
    verified_species,
    YFT = 130,
    BET = 129,
    SKJ = 108,
    ALB = 103
  )

  assessment_region <-
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
        xlim = plot$coordinates$limits$x,
        ylim = plot$coordinates$limits$y,
        expand = FALSE
      ) +
      ggplot2::labs(colour = "Region")
  )
}

#
as_area <- function(points, crs = 4326) {
  if (inherits(points, c("sf", "sfc", "bbox"))) {
    return(sf::st_as_sfc(points))
  }

  if (!all(c("lon", "lat") %in% names(points))) {
    rlang::abort("{.arg points} needs {.val lon} and {.val lat} columns.")
  }
  if (nrow(points) < 3) {
    rlang::abort("{.arg points} needs at least 3 distinct points.")
  }

  coords <- as.matrix(points[c("lon", "lat")])
  if (!identical(coords[1, ], coords[nrow(coords), ])) {
    coords <- rbind(coords, coords[1, ]) # close the ring
  }

  area <- sf::st_sfc(sf::st_polygon(list(coords)), crs = crs)
  if (!sf::st_is_valid(area)) {
    rlang::abort(
      "{.arg points} form a self-intersecting shape; check the point order."
    )
  }
  area
}
