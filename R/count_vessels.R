count_vessels <- function(
  ocean = NULL,
  flag = NULL,
  gear = NULL,
  year = NULL
) {
  glue::glue(
    "
  SELECT 
    OCEAN_CODE AS ocean_code, 
    FLAG_CODE AS flag_code, 
    GEAR_CODE AS gear_code, 
    YY AS year, 
    VESS_N AS n_vessels
  FROM ace.A_ACE
  WHERE {.sql_filter('OCEAN_CODE', ocean)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('GEAR_CODE', gear)}
  ORDER BY OCEAN_CODE, FLAG_CODE, GEAR_CODE, YY
  "
  ) |>
    .db_query()
}
