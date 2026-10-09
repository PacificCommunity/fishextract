#' Aggregate catch and effort by assessment region
#'
#' Assigns gridded catch and effort data to assessment regions and sums them by
#' region, species and gear. Regions with no data for a given species and gear
#' combination are retained with zeros, so the output is a complete grid.
#'
#' @details
#' Grid cells are assigned to regions using their centre point. The cell size is
#' taken as the smallest gap between unique `latd` values, and each coordinate
#' is shifted by half that gap (`lond`/`latd` are assumed to be the
#' south-west corner of each cell, and the same resolution is assumed for
#' longitude). Because centres sit away from the cell edges, cells are not
#' lost when a region boundary lies on a grid line (for example, at 150°).
#' Region boundaries that cut through the middle of a cell will assign it to
#' whichever region contains its centre.
#'
#' Cells are matched with [sf::st_within()], so any cell centre falling
#' exactly on a region boundary, or outside every region, is dropped.
#'
#' `VESS_N` is summed across cells, so vessels operating in more than one cell
#' are counted more than once. Treat it as vessel-cell counts rather than
#' unique vessels.
#'
#' @param catcheffort A data frame of gridded catch and effort, such as the
#'   output of [get_aggregated_catcheffort()]. Must contain the columns `lond`,
#'   `latd`, `SP_CODE`, `GEAR_CODE`, `sum_catch_mt`, `hhooks`, `VESS_N`, `days`
#'   and `sets`.
#' @param assessment_region An `sf` object of assessment region polygons with a
#'   `region_id` column, such as the output of [as_region()] or
#'   [get_md2_shp()].
#' @param crs Coordinate reference system of `catcheffort` coordinates, passed
#'   to [sf::st_as_sf()]. Defaults to `4326` (WGS 84).
#' @param show_plot Logical. If `TRUE`, prints a map of the aggregated catch
#'   overlaid with the assessment regions before aggregating. Defaults to
#'   `FALSE`.
#' @param ... Additional arguments passed to [plot_aggregated_catch()] when
#'   `show_plot = TRUE`, for example `facet_by = GEAR_CODE`. Ignored otherwise.
#'
#' @return A tibble with one row per combination of `region_id`, `SP_CODE` and
#'   `GEAR_CODE`, containing the summed `sum_catch_mt`, `hhooks`, `VESS_N`,
#'   `days` and `sets`. Combinations with no data are filled with `0`.
#'
#' @seealso [get_aggregated_catcheffort()], [as_region()], [get_md2_shp()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Define a simple two-region assessment area from vertices
#' bb <- tibble::tribble(
#'   ~region_id , ~lon , ~lat ,
#'   "1"        ,  110 ,   -0 ,
#'   "1"        ,  110 ,   20 ,
#'   "1"        ,  150 ,   20 ,
#'   "1"        ,  150 ,    0 ,
#'   "2"        ,  160 ,   -0 ,
#'   "2"        ,  160 ,   -5 ,
#'   "2"        ,  190 ,   -5 ,
#'   "2"        ,  190 ,  -10 ,
#'   "2"        ,  200 ,  -10 ,
#'   "2"        ,  200 ,    0
#' )
#'
#' x <- get_aggregated_catcheffort(
#'   flag = "KI",
#'   year = 2020:2025,
#'   species = "YFT",
#'   gear = c("L", "S")
#' )
#' y <- as_region(bb)
#' # or get regions from MD2 by model_id or species:
#' # y <- get_md2_shp(model_id = 130)
#'
#' # Aggregate and plot, faceting the map by gear
#' catcheffort_byregion(x, y, show_plot = TRUE, facet_by = GEAR_CODE)
#' }
catcheffort_byregion <- function(
  catcheffort,
  assessment_region,
  crs = 4326,
  show_plot = FALSE,
  ...
) {
  if (show_plot) {
    print(plot_assessment_region(
      assessment_region,
      plot = plot_aggregated_catch(catcheffort, ...)
    ))
  }

  unique_lats <- sort(unique(catcheffort$latd))
  latlon_gaps <- min(unique_lats - dplyr::lag(unique_lats, 1), na.rm = TRUE)
  latlon_offset <- latlon_gaps / 2

  catcheffort |>
    dplyr::mutate(
      lond_offset = .data$lond + latlon_offset,
      latd_offset = .data$latd + latlon_offset
    ) |>
    sf::st_as_sf(coords = c("lond_offset", "latd_offset"), crs = crs) |>
    sf::st_join(assessment_region, join = sf::st_within, left = FALSE) |>
    sf::st_drop_geometry() |>
    dplyr::summarise(
      sum_catch_mt = sum(.data$sum_catch_mt, na.rm = TRUE),
      hhooks = sum(.data$hhooks, na.rm = TRUE),
      VESS_N = sum(.data$VESS_N, na.rm = TRUE),
      days = sum(.data$days, na.rm = TRUE),
      sets = sum(.data$sets, na.rm = TRUE),
      .by = c(.data$region_id, .data$SP_CODE, .data$GEAR_CODE)
    ) |>
    tidyr::complete(
      region_id = assessment_region$region_id,
      .data$SP_CODE,
      .data$GEAR_CODE,
      fill = list(sum_catch_mt = 0, hhooks = 0, VESS_N = 0, days = 0, sets = 0)
    )
}
