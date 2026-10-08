#' Look up the weight measurement codes
#'
#' @param weight_code Optional character vector of weight codes to filter by.
#'   If `NULL`, all weight codes are returned.
#' @param refresh Logical. Force a re-query of the database and refresh
#'   the cache. Defaults to `FALSE`.
#'
#' @export
lookup_weight_codes <- function(weight_code = NULL, refresh = FALSE) {
  weight_codes_tbl <- pkg_cached(
    "weight_codes",
    compute = function() {
      "
      SELECT
        meas_id AS measurement_id, 
        meas_desc AS measurement_desc
      FROM ref.measurements
      WHERE meas_type = 'W'
      " |>
        db_query()
    },
    refresh = refresh
  )

  out <- if (is.null(weight_code)) {
    weight_codes_tbl
  } else {
    weight_codes_tbl |> dplyr::filter(.data$measurement_id %in% weight_code)
  }

  return(out)
}
