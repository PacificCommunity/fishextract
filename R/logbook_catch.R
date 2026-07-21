logbook_catch <- function(
  in_wcpfc = NULL,
  flag = NULL,
  gear = c("P", "S", "L", "T"),
  species = NULL,
  year = NULL
) {
  gear_suffix <- c(
    "P" = "ps",
    "S" = "pl",
    "L" = "ll",
    "T" = "tr"
  )

  # if (!is.character(gear) || length(gear) != 1L) {
  #   cli::cli_abort(
  #     "{.arg gear} must be a single string, options: {.val {names(gear_suffix)}}"
  #   )
  # }
  # if (!gear %in% names(gear_suffix)) {
  #   cli::cli_abort("{.arg gear} must be one of {.val {names(gear_suffix)}}.")
  # }

  convert_catch_to_mt <- function(df) {
    if ("sp_kg" %in% names(df)) {
      df <- df %>%
        dplyr::mutate(catch_mt = catch_kg / 1000, .keep = "unused")
    }
    df
  }

  get_logbook_catch <- function(.gear) {
    catch_column <-
      if (.gear == "L") {
        "coalesce(catch.sp_kg, 0) + coalesce(spdiscard_kg, 0) AS sp_kg"
      } else {
        "catch.sp_mt AS sp_mt"
      }
    catch_unit <-
      if (.gear == "L") {
        "sp_kg"
      } else {
        "sp_mt"
      }

    glue::glue(
      "
    WITH logbook_catch_temp AS(
    SELECT 
    flag_id AS FLAG_CODE, 
    year(sets.logdate) AS YY, 
    catch.sp_code AS SP_CODE,
    {catch_column}
  FROM log.trips_{gear_suffix[[.gear]]} trips 
  INNER JOIN log.sets_{gear_suffix[[.gear]]} sets on sets.log_trip_id = trips.log_trip_id
  INNER JOIN log.catch_{gear_suffix[[.gear]]} catch on catch.log_set_id = sets.log_set_id
  INNER JOIN ref.vessel_instances vesssels on vesssels.vessel_id = trips.vessel_id
    AND coalesce(depart_date, first_logdate) between start_date AND calculated_end_date
  WHERE {.sql_filter('in_wcpfc_area', in_wcpfc)}
  AND {.sql_filter('flag_id', flag)}
  AND {.sql_filter('sp_code', species)}
  )

  SELECT 
   FLAG_CODE,
    YY,
    SP_CODE,
    SUM({catch_unit}) AS {catch_unit}
    FROM logbook_catch_temp
  WHERE {.sql_filter('YY', year)}
  GROUP BY FLAG_CODE, YY, SP_CODE"
    ) |>
      .db_query() |>
      dplyr::mutate(GEAR_CODE = .gear)
  }

  purrr::map(gear, get_logbook_catch) |>
    dplyr::bind_rows() |>
    dplyr::mutate(sp_mt = dplyr::coalesce(sp_mt, sp_kg / 1000)) |>
    dplyr::select(-any_of("sp_kg"))
}
