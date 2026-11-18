get_vms <- function(
  year = NULL,
  flag = NULL,
  gear = NULL,
  species = NULL,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL
) {
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
    --FLAG_ID AS FLAG_CODE, 
--    FLEET_ID AS FLEET_CODE,
  --  LAT_SHORT,
   -- LON_SHORT,
    --GR AS GEAR_CODE, 
    --SP_ID AS SP_CODE, 
    --YR AS YY, 
    --MON AS month,
    --LEN_ID AS length_code,
    --LEN AS length_bin,
    --FREQ AS n,
    --ORIGIN_ID AS data_origin 
  FROM vms.vms_trips t
  INNER JOIN vms.vms_trip_efforts e ON e.vms_trip_id = t.vms_trip_id
  INNER JOIN ref.vessel_instances vi ON vi.vessel_id = t.vessel_id
      AND t.departure_date BETWEEN vi.start_date AND vi.calculated_end_date
  WHERE 1 = 1
    AND {.sql_filter('year', year)}
   AND {.sql_filter('FLAG_ID', flag)}
   -- AND {.sql_filter('GR', gear)}
  --  AND {.sql_filter('SP_ID', species)}
  --  AND {.sql_filter('FLAG_ID', exclude_flag, exclude = TRUE)}
  --  AND {.sql_filter('GR', exclude_gear, exclude = TRUE)}
   -- AND {.sql_filter('SP_ID', exclude_species, exclude = TRUE)}
  "
  ) |>
    db_query(database = "tufman2") |>
    dplyr::mutate(data_source = "vms")
}
