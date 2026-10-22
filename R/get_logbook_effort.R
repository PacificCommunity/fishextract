#' Retrieve WCPFC logbook effort data
#'
#' Queries logbook catch-and-effort tables for one or more gear types and
#' returns total effort (as determined by gear) summarised by flag, year, species
#' and gear.
#'
#' @param in_wcpfc Optional filter passed to `.sql_filter()` restricting
#'   records to those inside (or outside) the WCPFC Convention Area.
#' @param flag Optional character vector of flag codes to filter by.
#' @param fleet Optional character vector of fleet codes to filter by.
#' @param eez Optional character vector of eez codes to filter by.
#' @param gear Character vector of gear codes to query. One or more of
#'   `"P"` (purse seine), `"S"` (pole-and-line), `"L"` (longline), or
#'   `"T"` (troll). Defaults to all four.
#' @param year Optional numeric vector of years to filter by.
#' @param exclude_flag Optional character vector of flag codes to exclude.
#'   Defaults to `NULL`.
#' @param show_sql Logical.  If `TRUE`, prints the SQL code used to extract the data.
#' @param ... optional arguments that get passed to `db_query()` such as
#'   the database server and connection
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
  fleet = NULL,
  eez = NULL,
  gear = c("P", "S", "L", "T"),
  exclude_flag = NULL,
  show_sql = FALSE,
  ...
) {
  gear_suffix <- c(
    "P" = "pl",
    "S" = "ps",
    "L" = "ll",
    "T" = "tr"
  )

  generate_logbook_effort_query <- function(.gear) {
    suffix <- gear_suffix[[.gear]]

    # Only "other" gears (i.e, in the "_ot" tables) have the GEAR_CODE column
    gear_select <- if (.gear == "O") "GEAR_CODE" else glue::glue("'{.gear}'")
    gear_grouping <- if (.gear == "O") "GEAR_CODE," else ""

    fleet_col <- if (.gear == "O") {
      "NULL AS FLEET_CODE"
    } else {
      "FLEET_CODE"
    }
    fleet_grouping <- dplyr::if_else(.gear == "O", "", "FLEET_CODE,")

    gear_effort_cols <- list(
      L = c("hooks_n", "hk_bt_flt_n"),
      S = c("school_id", "set_time", "end_set_time", "effort_factor"),
      P = "bait",
      T = character(),
      O = c("set_time", "school_id", "hooks_n", "hk_bt_flt_n")
    )
    all_effort_cols <- unique(unlist(gear_effort_cols))

    effort_columns <-
      dplyr::if_else(
        all_effort_cols %in% gear_effort_cols[[.gear]],
        all_effort_cols,
        paste("NULL AS", all_effort_cols)
      ) |>
      stringr::str_flatten(", \n  ")

    effort_names <- stringr::str_flatten(all_effort_cols, ", \n  ")

    activity_id_col <- stringr::str_glue(
      "{tolower(ifelse(.gear=='O', 'L', .gear))}_activity_id"
    )
    switch(
      .gear,
      L = "l_activity_id AS act_id, hooks_n, hk_bt_flt_n",
      S = "s_activity_id AS act_id, school_id,  set_time, end_set_time, effort_factor",
      P = "p_activity_id AS act_id, bait",
      T = "t_atvitity_id AS act_id",
      O = "l_activity_id AS act_id, set_time, school_id, hooks_n, hk_bt_flt_n"
    )

    glue::glue(
      "
     SELECT 
      FLAG_CODE,
      {fleet_col},
      YY,
      logdate, 
      vessel_id, 
      vessel_name, 
      {gear_select} AS GEAR_CODE,
      {effort_names},
      trip_id, 
      set_id,
      activity_desc,
      latd,
      lond,
      eez_code
      FROM (
    SELECT 
      t.log_trip_id AS trip_id,
      s.log_set_id AS set_id,
            vi.vessel_id, 
      vi.vesselname AS vessel_name, 
      flag_id AS FLAG_CODE, 
      {fleet_col},
      year(s.logdate) AS YY, 
      s.logdate AS logdate, 
      {gear_grouping} 
      {effort_columns},
       r.CODE_DESC AS activity_desc,
      latd,
      lond, 
      s.eez_code
    FROM log.trips_{gear_suffix[[.gear]]} t 
    INNER JOIN log.sets_{gear_suffix[[.gear]]} s ON s.log_trip_id = t.log_trip_id
    INNER JOIN ref.sch_act_codes r ON r.CODE_ID = s.{activity_id_col} 
      AND r.FIELD_ID = '{ifelse(.gear=='O', 'L', .gear)}_ACT_ID'
    INNER JOIN ref.vessel_instances vi ON vi.vessel_id = t.vessel_id
      AND coalesce(depart_date, first_logdate) between start_date AND calculated_end_date
    WHERE {.sql_filter('in_wcpfc_area', in_wcpfc)}
      AND {.sql_filter('flag_id', flag)}
      AND {.sql_filter('eez_code', eez)}
      AND {.sql_filter('FLEET_CODE', fleet)}
      AND {.sql_filter('flag_id', exclude_flag, exclude = TRUE)}
    ) logbook_effort_temp
    WHERE {.sql_filter('YY', year)}"
    )
  }

  sql_query <-
    unique(dplyr::if_else(gear %in% names(gear_suffix), gear, "O")) |>
    purrr::map_chr(generate_logbook_effort_query) |>
    stringr::str_flatten("\nUNION ALL\n")

  if (show_sql) {
    .clean_sql(sql_query)
  }

  final_output <-
    db_query(sql_query, ...) |>
    dplyr::mutate(data_source = "logbook_effort")

  return(final_output)
}
