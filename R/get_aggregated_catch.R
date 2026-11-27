#' Pull 5x5 aggregated catch data
#'
#' Queries `best.A_BEST_AGG_CATCH` (joined to `best.A_BEST_AGG`) for catch
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
#' @param group_species Logical. Groups all seleceted species into a single catch value.
#'   Defaults to `FALSE`.
#' @param group_fleets Logical. Groups all seleceted fleets into a single catch value.
#'   Defaults to `TRUE`.
#' @param exclude_flag Optional character vector of flag codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_gear Optional character vector of gear codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_species Optional character vector of species codes to
#'   exclude. Defaults to `NULL`.
#' @param show_sql Logical.  If `TRUE`, prints the SQL code used to extract the data.
#' @param ... optional arguments that get passed to `db_query()` such as
#'   the database server and connection
#'
#' @return A data frame with columns `FLAG_CODE`, `GEAR_CODE`, `SP_CODE`,
#'   `YY`, `sum_catch_mt`, `latd`, `lond`, and `data_source`
#'   (`"aggregated_catch"`).
#'
#' @examples
#' \dontrun{
#' get_aggregated_catch(year = 2020:2023, species = "SKJ")
#' get_aggregated_catch(in_wcpfc = FALSE, exclude_gear = "S")
#' }
#'
#' @export
get_aggregated_catch <- function(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  gear = NULL,
  species = NULL,
  school = NULL,
  group_species = FALSE,
  group_fleets = TRUE,
  group_schools = TRUE,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  # broad_scale = FALSE,
  show_sql = FALSE,
  ...
) {
  # verify the inputted gear list
  if (!is.null(gear)) {
    gear <- match.arg(gear, lookup_gears()$GEAR_CODE, several.ok = TRUE)
  }
  gear_minus_ps <- setdiff(gear, "S")
  # fix at the 'A_BEST' table for now (all gears, low res for S)
  # can modify function later to extract the higher resoulation for S gear (if required)
  gear_table <- "A"

  numeric_if_notnull <- function(x) if (is.null(x)) NULL else as.numeric(x)
  sp_grouping <- dplyr::if_else(group_species, "", "SP_CODE,")
  school_grouping <- dplyr::if_else(group_schools, "", "Schass_code,")
  school_grouping_col <- dplyr::if_else(
    group_schools,
    "",
    "Schass_code AS SCH_CODE,"
  )
  fleet_grouping <- dplyr::if_else(group_fleets, "", "NULLIF(FLEET_CODE, ''),")
  fleet_grouping_col <- dplyr::if_else(
    group_fleets,
    "",
    "NULLIF(FLEET_CODE, '') AS FLEET_CODE,"
  )

  ps_query <-
    glue::glue(
      "
  SELECT 
    FLAG_CODE, 
    {fleet_grouping_col}
    GEAR_CODE, 
    {sp_grouping}
    {school_grouping_col}
    YY AS year, 
    MM AS month, 
    SUM(SP_MT) AS sum_catch_mt, 
    CAST(latd AS DECIMAL) AS latd, 
    CAST(lond AS DECIMAL) AS lond
  FROM best.{gear_table}_BEST_AGG_CATCH c
	  FULL JOIN best.{gear_table}_BEST_AGG a ON a.{gear_table}_BEST_ID = c.{gear_table}_BEST_ID
	  LEFT JOIN best.{gear_table}_BEST_AGG_SCHEFF s ON s.{gear_table}_SET_ID = c.{gear_table}_SET_ID
  WHERE 1 = 1
    AND {.sql_filter('in_wcpfc_area',  numeric_if_notnull(in_wcpfc))}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('GEAR_CODE', 'S')}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('SP_CODE', species)}
    AND {.sql_filter('Schass_code', school)}
    AND {.sql_filter('FLAG_CODE', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GEAR_CODE', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_CODE', exclude_species, exclude = TRUE)}
  GROUP BY 
    FLAG_CODE, 
    {fleet_grouping} 
    GEAR_CODE,
    {sp_grouping}
    {school_grouping}
    YY, 
    MM, 
    CAST(latd AS DECIMAL), 
    CAST(lond AS DECIMAL)
  "
    )

  sql_query <-
    glue::glue(
      "
  SELECT 
    FLAG_CODE, 
    {fleet_grouping_col}
    GEAR_CODE, 
    {sp_grouping}
    {school_grouping_col}
    YY AS year, 
    MM AS month, 
    SUM(SP_MT) AS sum_catch_mt, 
    CAST(latd AS DECIMAL) AS latd, 
    CAST(lond AS DECIMAL) AS lond
  FROM best.{gear_table}_BEST_AGG_CATCH c
	  FULL JOIN best.{gear_table}_BEST_AGG a ON a.{gear_table}_BEST_ID = c.{gear_table}_BEST_ID
	  LEFT JOIN best.{gear_table}_BEST_AGG_SCHEFF s ON s.{gear_table}_SET_ID = c.{gear_table}_SET_ID
  WHERE 1 = 1
    AND {.sql_filter('in_wcpfc_area',  numeric_if_notnull(in_wcpfc))}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('GEAR_CODE', gear_minus_ps)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('SP_CODE', species)}
    AND {.sql_filter('FLAG_CODE', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GEAR_CODE', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_CODE', exclude_species, exclude = TRUE)}
  GROUP BY 
    FLAG_CODE, 
    {fleet_grouping} 
    GEAR_CODE,
    {sp_grouping}
    {school_grouping}
    YY, 
    MM, 
    CAST(latd AS DECIMAL), 
    CAST(lond AS DECIMAL)
  "
    )

  sql_list <-
    if ("S" %in% gear) {
      list(ps_query, sql_query)
    } else {
      list(sql_query)
    }

  sql_query_bind <-
    sql_list |>
    stringr::str_flatten("\nUNION ALL\n")

  if (show_sql) {
    .clean_sql(sql_query_bind)
  }

  out <- db_query(sql_query_bind, ...)
  return(out)
}
