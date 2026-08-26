#' @export
get_weights <- function(
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
    FLAG_ID AS FLAG_CODE, 
    FLEET_ID AS FLEET_CODE,
    LAT_SHORT,
    LON_SHORT,
    GR AS GEAR_CODE, 
    SP_ID AS SP_CODE, 
    YR AS YY, 
    MON AS month,
    WT AS weight_bin,
    FREQ AS n,
    ORIGIN_ID AS data_origin 
  FROM wt.WT_MASTER
  WHERE 1 = 1
    AND {.sql_filter('YR', year)}
    AND {.sql_filter('FLAG_ID', flag)}
    AND {.sql_filter('GR', gear)}
    AND {.sql_filter('SP_ID', species)}
    AND {.sql_filter('FLAG_ID', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GR', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_ID', exclude_species, exclude = TRUE)}
  "
  ) |>
    db_query() |>
    dplyr::mutate(data_source = "weight_frequency")
}
