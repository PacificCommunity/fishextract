#' Extract aggregated catch data (either at 1x1 or 5x5 gridcell) from the BEST database
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
#' @param group_flags Logical; not currently implemented (see Note).
#'   Defaults to `FALSE`.
#' @param group_gears Logical; not currently implemented (see Note).
#'   Defaults to `FALSE`.
#' @param group_species Logical; not currently implemented (see Note).
#'   Defaults to `FALSE`.
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
  gear = NULL,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  fine_scale = FALSE
) {
  if (!fine_scale) {
    gear <- "A"
  }

  # need to add a bit to say that if fine scale only for which gears?

  agg_extract_effort_single_gear <- function(.gear) {
    effort_columns <-
      switch(
        .gear,
        L = "hhooks, VESS_N", # 5x5 gridcells
        S = "days", # 1x1 gridcells
        T = "days", # 1x1 gridcells
        P = "days", # 1x1 gridcells
        O = "VESS_N, days, sets, hhooks", # 1x1 gridcells
        A = "VESS_N, days, sets, hhooks" # 5x5 gridcells
      )

    glue::glue(
      "
  SELECT 
    FLAG_CODE, 
    GEAR_CODE, 
    YY AS year,
    MM AS month, 
    latd, 
    lond,
    {effort_columns} 
  FROM best.{.gear}_BEST_AGG 
  WHERE 1 = 1
    AND {.sql_filter('in_wcpfc_area', as.numeric(in_wcpfc))}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('FLAG_CODE', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GEAR_CODE', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_CODE', exclude_species, exclude = TRUE)}
  GROUP BY 
    FLAG_CODE, 
    GEAR_CODE,
    YY,
    MM, 
    latd, 
    lond,
    {effort_columns} 
  ORDER BY latd, lond, FLAG_CODE
  "
    ) |>
      db_query()
  }

  out <-
    purrr::map(gear, agg_extract_effort_single_gear) |>
    dplyr::bind_rows() |>
    dplyr::mutate(data_source = "logbook_effort")

  return(out)
}
