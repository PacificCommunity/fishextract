#' Extract aggregated effort data (either at 1x1 or 5x5 gridcell)
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
#'   and aditional columns for the effort metrics, which are determined by the gear selected.
#'
#' @examples
#' \dontrun{
#' get_aggregated_effort(year = 2020:2023)
#' get_aggregated_effort(in_wcpfc = FALSE, exclude_gear = "S")
#' }
#'
#' @export
get_aggregated_effort <- function(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  gear = c("L", "S", "T", "P", "O"),
  exclude_flag = NULL,
  exclude_gear = NULL,
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

  # the below code chunk was used when we went switching up between gears
  # effort_columns <-
  #   switch(
  #     .gear,
  #     L = "hhooks, VESS_N, NULL AS days, NULL AS sets",
  #     S = "days, NULL AS hhooks, NULL AS VESS_N, NULL AS sets",
  #     T = "days, NULL AS VESS_N, NULL AS sets, NULL AS hhooks",
  #     P = "days, NULL AS VESS_N, NULL AS sets, NULL AS hhooks",
  #     O = "VESS_N, days, sets, hhooks",
  #     A = "VESS_N, days, sets, hhooks"
  #   )

  effort_columns_grouping <- "VESS_N, days, sets, hhooks"

  numeric_if_notnull <- function(x) if (is.null(x)) NULL else as.numeric(x)

  sql_query <-
    glue::glue(
      "
  SELECT 
    FLAG_CODE, 
    NULLIF(FLEET_CODE, '') AS FLEET_CODE, 
    GEAR_CODE, 
    YY AS year,
    MM AS month, 
    latd, 
    lond,
    {effort_columns_grouping} 
  FROM best.{gear_table}_BEST_AGG 
  WHERE 1 = 1
    AND {.sql_filter('in_wcpfc_area', numeric_if_notnull(in_wcpfc))}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('GEAR_CODE', gear)}
    AND {.sql_filter('FLAG_CODE', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GEAR_CODE', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_CODE', exclude_species, exclude = TRUE)}
  GROUP BY 
    FLAG_CODE, 
    NULLIF(FLEET_CODE, ''), 
    GEAR_CODE,
    YY,
    MM, 
    latd, 
    lond,
    {effort_columns_grouping} 
  "
    )

  if (show_sql) {
    .clean_sql(sql_query)
  }

  out <- db_query(sql_query, ...)

  return(out)
}
