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
    gears |> dplyr::filter(GEAR_CODE %in% gear)
  }

  return(out)
}
