#' Summarise ACE catch by ocean, flag, gear, species and year
#'
#' Queries the ACE database and returns total catch (in metric tonnes),
#' summed by ocean, flag, gear, species and year. Any filter left as `NULL`
#' (the default) is not applied, so all values for that field are included.
#'
#' @param ocean A character vector of ocean codes to filter on (e.g.
#'   `"WX"`), or `NULL` (default) to include all oceans.
#' @param flag A character vector of flag codes to filter on (e.g.
#'   `c("ID", "VN")`), or `NULL` (default) to include all flags.
#' @param gear A character vector of gear codes to filter on (e.g. `"L"`
#'   for longline), or `NULL` (default) to include all gears.
#' @param species A character vector of species codes to filter on (e.g.
#'   `c("YFT", "SKJ")`), or `NULL` (default) to include all species.
#' @param year A numeric or character vector of years to filter on (e.g.
#'   `2024:2025`), or `NULL` (default) to include all years.
#' @param group_species Boolean. If TRUE, return combined catch across all species specified
#'
#' @return A [tibble::tibble()] with columns `OCEAN_CODE`, `FLAG_CODE`,
#'   `GEAR_CODE`, `SP_CODE`, `YY` and `sum_catch_mt`, one row per unique
#'   combination of ocean, flag, gear, species and year present in the
#'   (filtered) data. *Note*: if any of the grouping arguements (e.g., `group_species`
#'   or `group_flags`) are set to `TRUE`, these columns will be omitted from the
#'   output tibble.
#'
#' @details
#' Assumes `FLAG_CODE` is a column on `ace.A_ACE`. If it instead lives on
#' `ace.A_ACE_CATCH` or another joined table, update the SQL accordingly.
#'
#' @examples
#' \dontrun{
#' # Filter on everything
#' get_ace(
#'   ocean   = "WX",
#'   flag    = c("ID", "VN"),
#'   gear    = "L",
#'   species = c("YFT", "SKJ"),
#'   year    = 2024:2025
#' )
#'
#' # No filters at all — all oceans, flags, gears, species and years
#' get_ace()
#' }
#'
#' @importFrom glue glue
#'
#' @export
get_ace <- function(
  ocean = "WX",
  year = NULL,
  flag = NULL,
  gear = NULL,
  species = NULL,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  group_flags = FALSE,
  group_gears = FALSE,
  group_species = FALSE,
  ungroup_eez = FALSE
) {
  if (ungroup_eez) {
    ocean_column <- ""
    eez_column <- "EEZ_CODE,"
    eez_abbr <- "_EZ"
  } else {
    ocean_column <- "OCEAN_CODE,"
    eez_column <- ""
    eez_abbr <- ""
  }

  ace_extract <-
    glue::glue(
      "
  SELECT 
    {ocean_column}
    FLAG_CODE, 
    {eez_column}
    GEAR_CODE, 
    SP_CODE, 
    YY, 
    SUM(SP_MT) AS sum_catch_mt
  FROM ace.A_ACE{eez_abbr} a
    INNER JOIN ace.A_ACE{eez_abbr}_CATCH c 
      ON a.ACE{eez_abbr}_ID = c.ACE{eez_abbr}_ID
  WHERE 1 = 1
    AND {.sql_filter('OCEAN_CODE', ocean)}
    AND {.sql_filter('YY', year)}
    AND {.sql_filter('FLAG_CODE', flag)}
    AND {.sql_filter('GEAR_CODE', gear)}
    AND {.sql_filter('SP_CODE', species)}
    AND {.sql_filter('FLAG_CODE', exclude_flag, exclude = TRUE)}
    AND {.sql_filter('GEAR_CODE', exclude_gear, exclude = TRUE)}
    AND {.sql_filter('SP_CODE', exclude_species, exclude = TRUE)}
  GROUP BY 
     {ocean_column}
    FLAG_CODE, 
    {eez_column}
    GEAR_CODE, 
    SP_CODE, 
    YY
  "
    ) |>
    db_query() |>
    dplyr::mutate(data_source = if_else(ungroup_eez, "ace_byEEZ", "ace"))

  drop_cols <- c(
    if (group_species) "SP_CODE",
    if (group_flags) "FLAG_CODE",
    if (group_gears) "GEAR_CODE"
  )

  if (length(drop_cols) == 0) {
    return(ace_extract)
  }

  ace_extract |>
    dplyr::summarise(
      sum_catch_mt = sum(sum_catch_mt),
      .by = -dplyr::all_of(c(drop_cols, "sum_catch_mt"))
    )
}
