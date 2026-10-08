#' Look up the gear description for a given gear code
#'
#' @param gear Optional character vector of gear codes to filter by.
#'   If `NULL`, all gears are returned.
#' @param refresh Logical. Force a re-query of the database and refresh
#'   the cache. Defaults to `FALSE`.
#'
#' @export
lookup_gears <- function(gear = NULL, refresh = FALSE) {
  gears <- pkg_cached(
    "gears",
    compute = function() {
      "
      SELECT
        gear_code AS GEAR_CODE, 
        gear_desc AS GEAR_DESC
      FROM ref.gears
      " |>
        db_query()
    },
    refresh = refresh
  )

  out <- if (is.null(gear)) {
    gears
  } else {
    gears |> dplyr::filter(.data$GEAR_CODE %in% gear)
  }

  return(out)
}
