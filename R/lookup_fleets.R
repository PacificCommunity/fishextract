#' Look up all the fleets for a given country or gear
#'
#'
#' @param gear Optional character vector of gear codes to filter by.
#'   If `NULL`, all gears are returned.
#' @param flag Optional character vector of flag codes to filter by.
#'   If `NULL`, all flags are returned.
#' @param fleet Optional character vector of fleet codes to filter by.
#'   If `NULL`, all fleets are returned.
#' @param refresh Logical. Force a re-query of the database and refresh
#'   the cache. Defaults to `FALSE`.
#'
#' @export
lookup_fleets <- function(
  gear = NULL,
  flag = NULL,
  fleet = NULL,
  refresh = FALSE
) {
  fleets <- pkg_cached(
    "fleets",
    compute = function() {
      "
      SELECT
        flag_code AS FLAG_CODE,
        gear_code AS GEAR_CODE, 
        subfleet_code AS FLEET_CODE,
        fleet_desc AS FLEET_DESC
      FROM ref.fleet
      ORDER BY 
        FLAG_CODE, GEAR_CODE, FLEET_CODE
      " |>
        db_query()
    },
    refresh = refresh
  )

  out <- if (is.null(gear)) {
    fleets
  } else {
    fleets |> dplyr::filter(.data$GEAR_CODE %in% gear)
  }

  out <- if (is.null(flag)) {
    out
  } else {
    out |> dplyr::filter(.data$FLAG_CODE %in% flag)
  }

  out <- if (is.null(fleet)) {
    out
  } else {
    out |> dplyr::filter(.data$FLEET_CODE %in% fleet)
  }

  return(out)
}
