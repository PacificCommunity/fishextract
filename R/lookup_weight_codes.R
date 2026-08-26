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
    weight_codes_tbl |> dplyr::filter(measurement_id %in% weight_code)
  }

  return(out)
}
