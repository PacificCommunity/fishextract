#' Look up the length measurement codes
#'
#' @param length_code Optional character vector of length codes to filter by.
#'   If `NULL`, all length codes are returned.
#' @param refresh Logical. Force a re-query of the database and refresh
#'   the cache. Defaults to `FALSE`.
#'
#' @export
lookup_length_codes <- function(length_code = NULL, refresh = FALSE) {
  length_codes_tbl <- pkg_cached(
    "length_codes",
    compute = function() {
      "
      SELECT
        meas_id AS measurement_id, 
        meas_desc AS measurement_desc
      FROM ref.measurements
      WHERE meas_type = 'L'
      " |>
        db_query()
    },
    refresh = refresh
  )

  out <- if (is.null(length_code)) {
    length_codes_tbl
  } else {
    length_codes_tbl |> dplyr::filter(.data$measurement_id %in% length_code)
  }

  return(out)
}
