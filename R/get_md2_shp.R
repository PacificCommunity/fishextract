#' Extract MD2 shape file for a given model number or species
#'
#' Queries region boundary polygons for a given model from the MD2 database
#' and layers them onto an existing Pacific map (typically from
#' `plot_pacific()`), coloured by `region_id`.
#'
#' @param model_id Optional (unless `species` not specified). MD2 `model_id` number
#' @param species Optional (unless `model_id` not specified). Species used to identify `model_id`.
#'
#' @return A ggplot object with region boundary polygons added.
#'
#' @export
get_md2_shp <- function(
  model_id = NULL,
  species = NULL,
  crs = 4326
) {
  if (is.null(model_id) == is.null(species)) {
    cli::cli_abort(
      "Specify exactly one of {.arg model_id} or {.arg species}."
    )
  }

  verified_species <- rlang::arg_match(species, c("YFT", "BET", "ALB", "SKJ"))
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
        "SELECT DiSTINCT
          r.region_id,
          --r.bounding_box_id,
          CAST(b.geom.STAsText() AS VARCHAR(8000)) as geometry,
          b.model_id
        FROM md2.app.region_bounding_box r
        JOIN md2.app.region b ON r.region_id = b.region_id
        WHERE b.model_id = {model_id}"
      )
    ) |>
    sf::st_as_sf(wkt = "geometry", crs = crs) |>
    sf::st_shift_longitude()
}
