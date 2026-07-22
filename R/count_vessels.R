#' Count vessels by ocean, flag, gear, and year
#'
#' Queries the `ace.A_ACE` table for vessel counts, optionally filtered by
#' ocean, flag state, gear type, and/or year. Filters are built via
#' `.sql_filter()`, so any parameter left as `NULL` is excluded from the
#' `WHERE` clause rather than matched literally.
#'
#' @param ocean Character. Ocean code to filter on. `NULL` (default)
#'   returns all oceans.
#' @param flag Character. Flag code to filter on. `NULL` (default)
#'   returns all flags.
#' @param gear Character. Gear code to filter on. `NULL` (default)
#'   returns all gears.
#' @param year Integer. Year to filter on. `NULL` (default) returns all
#'   years.
#'
#' @return A data frame (or tibble, depending on `.db_query()`) with one
#'   row per ocean/flag/gear/year combination, giving `ocean_code`,
#'   `flag_code`, `gear_code`, `year`, and `n_vessels`.
#'
#' @examples
#' \dontrun{
#' count_vessels(ocean = "ATL", year = 2023)
#' count_vessels(flag = "ESP", gear = "PS")
#' }
#'
#' @export
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
