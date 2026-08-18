#' @export
lookup_fleets <- function(gear = NULL, flag = NULL, refresh = FALSE) {
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
    fleets |> dplyr::filter(GEAR_CODE %in% gear)
  }

  out <- if (is.null(flag)) {
    fleets
  } else {
    fleets |> dplyr::filter(FLAG_CODE %in% flag)
  }

  return(out)
}
