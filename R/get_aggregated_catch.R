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
#' @param exclude_flag Optional character vector of flag codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_gear Optional character vector of gear codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_species Optional character vector of species codes to
#'   exclude. Defaults to `NULL`.
#' @param broad_scale Logical.  If `TRUE`, gears will return 5x5 gridcell instead of the fine scale 1x1
#'   degree gridcell. Note that 1x1 gridcell is only available for purse-seine.
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
  group_species = FALSE,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  broad_scale = FALSE,
  show_sql = FALSE,
  ...
) {
  gear <- match.arg(gear, lookup_gears()$GEAR_CODE, several.ok = TRUE)

  generate_agg_catch_query <- function(.gear) {
    # only purse-seine has 1x1 resolution
    if (broad_scale & .gear == "S") {
      gear_table <- "A"
    } else {
      gear_table <- .gear
    }

    sp_grouping <- dplyr::if_else(group_species, "", "SP_CODE,")
    numeric_if_notnull <- function(x) if (is.null(x)) NULL else as.numeric(x)

    glue::glue(
      "
  SELECT 
    FLAG_CODE, 
    NULLIF(FLEET_CODE, '') AS FLEET_CODE, 
    GEAR_CODE, 
    {sp_grouping}
    YY AS year, 
    MM AS month, 
    SUM(SP_MT) AS sum_catch_mt, 
    CAST(latd AS DECIMAL) AS latd, 
CAST(lond AS DECIMAL) AS lond
  FROM best.{.gear}_BEST_AGG_CATCH c
	  FULL JOIN best.{.gear}_BEST_AGG a ON a.{.gear}_BEST_ID = c.{.gear}_BEST_ID
  WHERE 1 = 1
    AND {.sql_filter('in_wcpfc_area',  numeric_if_notnull(in_wcpfc))}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('SP_CODE', species)}
    AND {.sql_filter('FLAG_CODE', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GEAR_CODE', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_CODE', exclude_species, exclude = TRUE)}
  GROUP BY 
    FLAG_CODE, 
    NULLIF(FLEET_CODE, ''), 
    GEAR_CODE,
    {sp_grouping}
    YY, 
    MM, 
    CAST(latd AS DECIMAL), 
    CAST(lond AS DECIMAL)
  "
    )
  }

  sql_query <-
    unique(gear) |>
    purrr::map_chr(generate_agg_catch_query) |>
    stringr::str_flatten("\nUNION ALL\n")

  if (show_sql) {
    .clean_sql(sql_query)
  }

  out <-
    db_query(sql_query, ...)

  return(out)
}
