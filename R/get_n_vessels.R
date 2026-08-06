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
#' @return A data frame (or tibble, depending on `db_query()`) with one
#'   row per ocean/flag/gear/year combination, giving `ocean_code`,
#'   `flag_code`, `gear_code`, `year`, and `n_vessels`.
#'
#' @examples
#' \dontrun{
#' get_n_vessels(ocean = "ATL", year = 2023)
#' get_n_vessels(flag = "ESP", gear = "PS")
#' }
#'
#' @export
get_n_vessels <- function(
  ocean = "WX",
  flag = NULL,
  gear = NULL,
  year = NULL,
  group_species = FALSE,
  group_flags = FALSE,
  group_gears = FALSE,
  include_size_classes = FALSE
) {
  vessel_class_cols <- if (include_size_classes) {
    c("VESS_CAT1_N", "VESS_CAT2_N", "VESS_CAT3_N", "VESS_CAT4_N")
  } else {
    character()
  }

  select_cols <- c(
    "OCEAN_CODE",
    "FLAG_CODE",
    "GEAR_CODE",
    "YY",
    vessel_class_cols,
    "VESS_N AS n_vessels"
  )

  n_vessels_extract <-
    glue::glue(
      "
  SELECT 
    {paste(select_cols, collapse = ',\n ')}
  FROM ace.A_ACE
  WHERE {.sql_filter('OCEAN_CODE', ocean)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('GEAR_CODE', gear)}
  ORDER BY OCEAN_CODE, FLAG_CODE, GEAR_CODE, YY
  "
    ) |>
    db_query() |>
    dplyr::mutate(data_source = "ace_n_vessels")

  drop_cols <- c(
    if (group_species) "SP_CODE",
    if (group_flags) "FLAG_CODE",
    if (group_gears) "GEAR_CODE"
  )

  if (length(drop_cols) == 0) {
    return(n_vessels_extract)
  }

  n_vessels_extract |>
    dplyr::summarise(
      n_vessels = sum(n_vessels),
      .by = -dplyr::all_of(c(drop_cols, "n_vessels"))
    )
}
