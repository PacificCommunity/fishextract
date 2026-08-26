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
    length_codes_tbl |> dplyr::filter(measurement_id %in% length_code)
  }

  return(out)
}
