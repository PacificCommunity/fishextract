#' Retrieve logbook catch data
#'
#' Queries logbook catch-and-effort tables for one or more gear types and
#' returns total catch (metric tonnes) summarised by flag, year, species
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
#' @param species Optional character vector of species codes to filter by.
#' @param year Optional numeric vector of years to filter by.
#' @param exclude_flag Optional character vector of flag codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_species Optional character vector of species codes to exclude.
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
#'     \item{sp_mt}{Catch, in metric tonnes.}
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
get_logbook_catch <- function(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  fleet = NULL,
  eez = NULL,
  gear = c("P", "S", "L", "T", "O"),
  species = NULL,
  exclude_flag = NULL,
  exclude_species = NULL,
  show_sql = FALSE,
  ...
) {
  gear_suffix <- c(
    "P" = "pl",
    "S" = "ps",
    "L" = "ll",
    "T" = "tr",
    "O" = "ot"
  )

  # convert_catch_to_mt <- function(df) {
  #   if ("sp_kg" %in% names(df)) {
  #     df <- df %>%
  #       dplyr::mutate(catch_mt = catch_kg / 1000, .keep = "unused")
  #   }
  #   df
  # }

  generate_logbook_query <- function(.gear) {
    suffix <- gear_suffix[[.gear]]

    # Longline catch (incl. discards) is only available in kg; all other
    # gears report catch directly in tonnes.
    catch_expr <-
      if (.gear == "L") {
        "(coalesce(c.sp_kg, 0) + coalesce(c.spdiscard_kg, 0)) / 1000"
      } else {
        "c.sp_mt"
      }

    # Only "other" gears (i.e, in the "_ot" tables) have the GEAR_CODE column
    gear_select <- if (.gear == "O") "GEAR_CODE" else glue::glue("'{.gear}'")
    gear_grouping <- if (.gear == "O") "GEAR_CODE," else ""

    fleet_col <- if (.gear == "O") {
      "NULL AS FLEET_CODE"
    } else {
      "NULLIF(FLEET_CODE, '') AS FLEET_CODE"
    }
    fleet_grouping <- dplyr::if_else(
      .gear == "O",
      "",
      "NULLIF(FLEET_CODE, ''),"
    )
    activity_id_col <- stringr::str_glue(
      "{tolower(ifelse(.gear=='O', 'L', .gear))}_activity_id"
    )

    glue::glue(
      "
    SELECT
      flag_id AS FLAG_CODE,
      {fleet_col},
      year(s.logdate) AS YY,
      s.logdate AS logdate, 
      vi.vessel_id, 
      vi.vesselname AS vessel_name, 
      {gear_select} AS GEAR_CODE,
      c.sp_code AS SP_CODE,
      SUM({catch_expr}) AS sum_catch_mt,
      t.log_trip_id AS trip_id,
      s.log_set_id AS set_id,
      r.CODE_DESC AS activity_desc,
      latd,
      lond, 
      s.eez_code
    FROM log.trips_{suffix} t
    INNER JOIN log.sets_{suffix} s ON s.log_trip_id = t.log_trip_id
        INNER JOIN ref.sch_act_codes r ON r.CODE_ID = s.{activity_id_col} 
      AND r.FIELD_ID = '{ifelse(.gear=='O', 'L', .gear)}_ACT_ID'
    INNER JOIN log.catch_{suffix} c ON c.log_set_id = s.log_set_id
    INNER JOIN ref.vessel_instances vi ON vi.vessel_id = t.vessel_id
      AND coalesce(depart_date, first_logdate) BETWEEN start_date AND calculated_end_date
    WHERE {.sql_filter('in_wcpfc_area', in_wcpfc)}
      AND {.sql_filter('flag_id', flag)}
      AND {.sql_filter('FLEET_CODE', fleet)}
      AND {.sql_filter('sp_code', species)}
      AND {.sql_filter('eez_code', eez)}
      AND {.sql_filter('flag_id', exclude_flag, exclude = TRUE)}
      AND {.sql_filter('sp_code', exclude_species, exclude = TRUE)}
      AND {.sql_filter('year(s.logdate)', year)}
    GROUP BY
      t.log_trip_id, 
      s.log_set_id, 
      r.CODE_DESC,
      vi.vessel_id, 
      vi.vesselname,
      latd, 
      lond, 
      s.eez_code,
      flag_id, 
      {fleet_grouping}
      year(s.logdate), 
      s.logdate, 
      {gear_grouping}
      c.sp_code"
    )
  }

  sql_query <-
    unique(dplyr::if_else(gear %in% names(gear_suffix), gear, "O")) |>
    purrr::map_chr(generate_logbook_query) |>
    stringr::str_flatten("\nUNION ALL\n")

  if (show_sql) {
    .clean_sql(sql_query)
  }

  combined_output <- db_query(sql_query, ...)

  nrow_removed <-
    combined_output |>
    dplyr::filter(is.na(.data$sum_catch_mt)) |>
    nrow()

  if (nrow_removed > 0) {
    warning(
      glue::glue(
        "{nrow_removed} rows removed from output due to missing catch weight values. 
        These records may have catch reported only as numbers rather than weight."
      ),
      call. = FALSE
    )
  }

  final_output <-
    combined_output |>
    dplyr::filter(!is.na(.data$sum_catch_mt)) |>
    dplyr::mutate(data_source = "logbook_catch")

  return(final_output)
}
