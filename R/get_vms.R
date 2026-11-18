#' @export
get_vms <- function(
  year = NULL,
  flag = NULL,
  # gear = NULL,
  exclude_flag = NULL,
  # exclude_gear = NULL,
  show_sql = FALSE,
  ...
) {
  sql_query <-
    glue::glue(
      "
  SELECT 
  t.vms_trip_id,
  t.vessel_id,
  t.departure_date,
  t.return_date,
   t.departure_port_id,
   t.return_port_id,
   e.eez_code, 
   e.year,
   e.day_at_sea,
   e.day_fishing,
   e.month, 
   e.rfmo, 
   e.non_fishing_period_applied,
   vi.flag_id
  FROM vms.vms_trips t
  INNER JOIN vms.vms_trip_efforts e ON e.vms_trip_id = t.vms_trip_id
  INNER JOIN ref.vessel_instances vi ON vi.vessel_id = t.vessel_id
      AND t.departure_date BETWEEN vi.start_date AND vi.calculated_end_date
  WHERE 1 = 1
    AND {.sql_filter('year', year)}
    AND {.sql_filter('FLAG_ID', flag)}
    AND {.sql_filter('FLAG_ID', exclude_flag, exclude = TRUE)}
  "
    )

  if (show_sql) {
    .clean_sql(sql_query)
  }

  out <-
    sql_query |>
    db_query(database = "tufman2") |>
    dplyr::mutate(data_source = "vms")

  return(out)
}
