#' Get length-frequency data
#'
#' @param year,flag,gear,species filters to include (`NULL` = no filter).
#' @param exclude_flag,exclude_gear,exclude_species filters to exclude.
#'
#' @return A tibble of length-frequency records.
#' @export
get_lengths <- function(
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
    LEN_ID AS length_code,
    LEN AS length_bin,
    FREQ AS n,
    ORIGIN_ID AS data_origin 
  FROM lf.LF_MASTER
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
    dplyr::mutate(data_source = "length_frequency")
}
