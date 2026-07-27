get_aggregated_catch <- function(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  gear = NULL,
  species = NULL,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  group_flags = FALSE,
  group_gears = FALSE,
  group_species = FALSE
) {
  agg_extract <-
    glue::glue(
      "
  SELECT 
    FLAG_CODE, 
    GEAR_CODE, 
    SP_CODE, 
    YY, 
    SUM(SP_MT) AS sum_catch_mt, latd, lond
  FROM best.A_BEST_AGG_CATCH c
	  INNER JOIN best.A_BEST_AGG a ON a.A_BEST_ID = c.A_BEST_ID
  WHERE 1 = 1
    AND {.sql_filter('in_wcpfc_area', as.numeric(in_wcpfc))}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('GEAR_CODE', gear)}
    AND {.sql_filter('SP_CODE', species)}
    AND {.sql_filter('FLAG_CODE', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GEAR_CODE', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_CODE', exclude_species, exclude = TRUE)}
  GROUP BY 
    FLAG_CODE, 
    GEAR_CODE,
    SP_CODE, 
    YY, latd, lond
  "
    ) |>
    .db_query() |>
    dplyr::mutate(data_source = "aggregated_catch")
  return(agg_extract)
}
