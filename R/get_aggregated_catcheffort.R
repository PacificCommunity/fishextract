#' Extract aggregated catch and effort data (either at 1x1 or 5x5 gridcell)
#'
#' Queries `best.A_BEST_AGG` for effort (effort type determined by the selected gear)
#' summed by flag, gear, species, year and location, with optional filters
#' to include/exclude specific flags, gears, species, years, and to
#' restrict to the WCPFC convention area.
#'
#' @param in_wcpfc Logical; if `TRUE` (the default), restrict results to
#'   the WCPFC convention area.
#' @param year Optional numeric vector of years (`YY`) to include. Defaults
#'   to `NULL` (all years).
#' @param flag Optional character vector of flag codes to include. Defaults
#'   to `NULL` (all flags).
#' @param gear Optional character vector of gear codes to include. Defaults
#'   to `NULL` (all gears).
#' @param species Optional character vector of species codes to include.
#'   Defaults to `NULL` (all species).
#' @param exclude_flag Optional character vector of flag codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_gear Optional character vector of gear codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_species Optional character vector of species codes to
#'   exclude. Defaults to `NULL`.
#' @param group_species Logical. Groups all seleceted species into a single catch value.
#'   Defaults to `FALSE`.
#' @param show_sql Logical.  If `TRUE`, prints the SQL code used to extract the data.
#' @param ... optional arguments that get passed to `db_query()` such as
#'   the database server and connection
#'
#' @return A data frame with columns `FLAG_CODE`, `GEAR_CODE`, `SP_CODE`,
#'   `YY`, `sum_catch_mt`, `latd`, `lond`, and `data_source`
#'   and aditional columns for the effort metrics, which are determined by the gear selected.
#'
#' @examples
#' \dontrun{
#' get_aggregated_catcheffort(year = 2020:2023)
#' get_aggregated_catcheffort(in_wcpfc = FALSE, exclude_gear = "S")
#' }
#'
#' @export
get_aggregated_catcheffort <- function(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  gear = c("L", "S", "T", "P", "O"),
  species = NULL,
  school = NULL,
  exclude_flag = NULL,
  exclude_gear = NULL,
  group_schools = TRUE,
  exclude_species = NULL,
  # broad_scale = FALSE,
  show_sql = FALSE,
  ...
) {
  # verify the inputted gear list
  gear <- match.arg(gear, lookup_gears()$GEAR_CODE, several.ok = TRUE)

  # fix at the all table for now
  # can modify function later to extract the higher resoulation for S gear (if required)
  gear_table <- "A"
  effort_columns_grouping <- "VESS_N, hhooks"

  school_grouping <- dplyr::if_else(group_schools, "", "Schass_code,")
  school_grouping_col <- dplyr::if_else(
    group_schools,
    "",
    "Schass_code AS SCH_CODE,"
  )

  numeric_if_notnull <- function(x) if (is.null(x)) NULL else as.numeric(x)

  sql_query <-
    glue::glue(
      "
  SELECT 
    FLAG_CODE, 
    NULLIF(FLEET_CODE, '') AS FLEET_CODE,  
    SP_CODE,
    GEAR_CODE, 
    YY AS year,
    MM AS month, 
    CAST(a.latd AS DECIMAL) AS latd, 
    CAST(a.lond AS DECIMAL) AS lond,
    SUM(SP_MT) AS sum_catch_mt, 
    {effort_columns_grouping}, 
    SUM(days_sch) AS days, 
    SUM(sets_sch) AS sets 
  FROM best.{gear_table}_BEST_AGG_CATCH c
	  FULL JOIN best.{gear_table}_BEST_AGG a ON a.{gear_table}_BEST_ID = c.{gear_table}_BEST_ID
    LEFT JOIN best.{gear_table}_BEST_AGG_SCHEFF s ON a.{gear_table}_BEST_ID = s.{gear_table}_BEST_ID
  WHERE 1 = 1
    AND {.sql_filter('in_wcpfc_area', numeric_if_notnull(in_wcpfc))}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('GEAR_CODE', gear)}
    AND {.sql_filter('SP_CODE', species)}
    AND {.sql_filter('Schass_code', school)}
    AND {.sql_filter('FLAG_CODE', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GEAR_CODE', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_CODE', exclude_species, exclude = TRUE)}
  GROUP BY 
    FLAG_CODE, 
    NULLIF(FLEET_CODE, ''), 
    SP_CODE,
    GEAR_CODE,
    YY,
    MM,
    CAST(latd AS DECIMAL), 
    CAST(lond AS DECIMAL),
    {school_grouping}
    {effort_columns_grouping} 
  "
    )

  if (show_sql) {
    .clean_sql(sql_query)
  }

  out <- db_query(sql_query, ...)

  return(out)
}
