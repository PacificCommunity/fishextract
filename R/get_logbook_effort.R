#' Retrieve WCPFC logbook effort data
#'
#' Queries logbook catch-and-effort tables for one or more gear types and
#' returns total effort (as determined by gear) summarised by flag, year, species
#' and gear.
#'
#' @param in_wcpfc Optional filter passed to `.sql_filter()` restricting
#'   records to those inside (or outside) the WCPFC Convention Area.
#' @param flag Optional character vector of flag codes to filter by.
#' @param gear Character vector of gear codes to query. One or more of
#'   `"P"` (purse seine), `"S"` (pole-and-line), `"L"` (longline), or
#'   `"T"` (troll). Defaults to all four.
#' @param species Optional character vector of species codes to filter by.
#' @param year Optional numeric vector of years to filter by.
#'
#' @return A tibble with one row per flag/year/species/gear combination,
#'   containing:
#'   \describe{
#'     \item{FLAG_CODE}{Flag code.}
#'     \item{YY}{Year.}
#'     \item{SP_CODE}{Species code.}
#'     \item{<effort>}{The effort column(s) are determined by the gear_code provided}
#'     \item{GEAR_CODE}{Gear code (`"P"`, `"S"`, `"L"`, or `"T"`).}
#'   }
#'
#' @details
#' For each requested gear, catch is pulled by joining
#' `log.trips_*` -> `log.sets_*` -> `log.catch_*` (table suffix set by
#' `gear_suffix`), restricted to vessel instances active over the trip
#' period (via `ref.vessel_instances`). Longline (`"L"`) catch is queried
#' and summed in kilograms (`sp_kg`, including discards) since it is
#' recorded at that resolution; all other gears are summed directly in
#' tonnes (`sp_mt`). After all gears are queried and row-bound, any
#' `sp_kg` totals are converted to tonnes and coalesced into `sp_mt`,
#' and the now-redundant `sp_kg` column is dropped.
#'
#' @note `convert_catch_to_mt()` is defined inside the function but is
#'   not currently called anywhere in the body — the kg-to-tonnes
#'   conversion for longline catch is instead handled directly in the
#'   final `dplyr::mutate()` step. Left in place here as-is; flag for
#'   removal or wiring in if that was the intent.
#'
#' @examples
#' \dontrun{
#' # All gears, all flags/species/years
#' get_logbook_catch()
#'
#' # Purse seine and longline catch for one flag, 2020-2023
#' get_logbook_catch(flag = "FJ", gear = c("P", "L"), year = 2020:2023)
#' }
#'
#' @export
get_logbook_effort <- function(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  gear = c("P", "S", "L", "T"),
  species = NULL,
  exclude_flag = NULL,
  exclude_species = NULL
) {
  gear_suffix <- c(
    "P" = "pl",
    "S" = "ps",
    "L" = "ll",
    "T" = "tr"
  )

  # convert_effort_to_mt <- function(df) {
  #   if ("sp_kg" %in% names(df)) {
  #     df <- df %>%
  #       dplyr::mutate(effort_mt = effort_kg / 1000, .keep = "unused")
  #   }
  #   df
  # }

  logbook_effort_extract <- function(.gear) {
    effort_columns <-
      switch(
        .gear,
        L = "hooks_n, hk_bt_flt_n",
        S = "set_time, end_set_time, effort_factor"
      )

    glue::glue(
      "
    WITH logbook_effort_temp AS(
    SELECT 
      trips.log_trip_id AS trip_id,
      sets.log_set_id AS set_id,
      flag_id AS FLAG_CODE, 
      year(sets.logdate) AS YY,
      {effort_columns}
    FROM log.trips_{gear_suffix[[.gear]]} trips 
    INNER JOIN log.sets_{gear_suffix[[.gear]]} sets ON sets.log_trip_id = trips.log_trip_id
    INNER JOIN ref.vessel_instances vesssels ON vesssels.vessel_id = trips.vessel_id
      AND coalesce(depart_date, first_logdate) between start_date AND calculated_end_date
    WHERE {.sql_filter('in_wcpfc_area', in_wcpfc)}
      AND {.sql_filter('flag_id', flag)}
      AND {.sql_filter('sp_code', species)}
      AND {.sql_filter('flag_id', exclude_flag, exclude = TRUE)}
      AND {.sql_filter('sp_code', exclude_species, exclude = TRUE)}
    )

    SELECT 
      FLAG_CODE,
      YY,
      {effort_columns}, 
      trip_id, 
      set_id
    FROM logbook_effort_temp
    WHERE {.sql_filter('YY', year)}
    GROUP BY 
      FLAG_CODE, 
      YY, 
      {effort_columns}, 
      trip_id, 
      set_id"
    ) |>
      db_query() |>
      dplyr::mutate(GEAR_CODE = .gear) |>
      dplyr::relocate(GEAR_CODE, .before = 1)
  }

  # run for each gear that is specified and combine
  combined_output <-
    purrr::map(gear, logbook_effort_extract) |>
    dplyr::bind_rows() #|>
  # (\(df) {
  #   if ("sp_kg" %in% names(df)) df else dplyr::mutate(df, sp_kg = NA_real_)
  # })() |>
  # (\(df) {
  #   if ("sp_mt" %in% names(df)) df else dplyr::mutate(df, sp_mt = NA_real_)
  # })() |>
  # dplyr::mutate(sum_effort_mt = dplyr::coalesce(sp_mt, sp_kg / 1000)) |>
  # dplyr::select(-any_of(c("sp_kg", "sp_mt")))

  # nrow_removed <-
  #   combined_output |>
  #   dplyr::filter(is.na(sum_catch_mt)) |>
  #   nrow()

  # if (nrow_removed > 0) {
  #   warning(
  #     glue::glue(
  #       "{nrow_removed} rows removed from output due to missing catch weight values. These records may have catch reported only as numbers rather than weight."
  #     ),
  #     call. = FALSE
  #   )
  # }

  final_output <-
    combined_output |>
    # dplyr::filter(!is.na(sum_catch_mt)) |>
    dplyr::mutate(data_source = "logbook_effort")

  return(final_output)
}
