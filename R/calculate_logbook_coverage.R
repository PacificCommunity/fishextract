#' Calculate logbook reporting coverage against ACE catch estimates
#'
#' Compares logbook-reported catch against ACE (aggregated catch
#' estimate) catch for the same flag/gear/species/year strata, and
#' calculates the proportional shortfall of logbook catch relative to
#' ACE catch.
#'
#' @param in_wcpfc Optional logical. If not `NULL`, restricts `sum_ace()`
#'   to the `"WX"` ocean code and is passed through to `logbook_catch()`
#'   as its WCPFC-area filter; if `NULL`, no ocean filter is applied.
#' @param flag Optional character vector of flag codes to filter by.
#' @param gear Optional character vector of gear codes to filter by
#'   (passed to `logbook_catch()`; `sum_ace()` is not filtered by gear).
#' @param species Optional character vector of species codes to filter by.
#' @param year Optional numeric vector of years to filter by.
#' @param exclude_flag Optional character vector of flag codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_gear Optional character vector of gear codes to exclude.
#'   Defaults to `NULL`.
#' @param exclude_species Optional character vector of species codes to exclude.
#'   Defaults to `NULL`.
#' @param group_species Logical. If `TRUE`, catch is summed across all
#'   species within each remaining grouping (i.e. `SP_CODE` is dropped
#'   before summarising). Defaults to `FALSE`.
#' @param ... optional arguments that get passed to `db_query()` such as
#'   the database server and connection
#'
#' @return A tibble of `ace_catch`, `logbook_catch`, and `coverage`
#'   (`(ace_catch - logbook_catch) / ace_catch`) by flag, year, species
#'   (unless `group_species = TRUE`), and gear.
#'
#' @details
#' `ace_catch` is obtained via `get_ace()` and `logbook_catch` via
#' `get_logbook_catch()`, using the same flag/gear/species/year filters.
#' The two are `full_join()`ed so that strata present in only one source
#' are retained, with missing catch values filled to zero via
#' `tidyr::replace_na()`. If `group_species = TRUE`, `logbook_catch` is
#' re-summed across species (`SP_CODE` dropped from the grouping); a
#' `coverage` column is then calculated as the proportional difference
#' between ACE and logbook catch.
#'
#'
#' @examples
#' \dontrun{
#' calculate_logbook_coverage(in_wcpfc = TRUE)
#' calculate_logbook_coverage(in_wcpfc = TRUE, group_species = TRUE)
#' }
#'
#' @export
calculate_logbook_coverage <-
  function(
    in_wcpfc = TRUE,
    year = NULL,
    flag = NULL,
    gear = NULL,
    species = NULL,
    exclude_flag = NULL,
    exclude_gear = NULL,
    exclude_species = NULL,
    group_species = TRUE,
    ...
  ) {
    ace_catch <-
      get_ace(
        ocean = if (is.null(in_wcpfc)) NULL else "WX",
        flag = flag,
        # gear = gear,
        species = species,
        year = year,
        group_species = FALSE
      ) |>
      dplyr::rename(ace_catch = .data$sum_catch_mt) |>
      dplyr::select(-dplyr::any_of("OCEAN_CODE"))

    logbook_catch <-
      get_logbook_catch(
        in_wcpfc = in_wcpfc,
        flag = flag,
        # gear = gear,
        species = species,
        year = year,
        ...
      ) |>
      dplyr::rename(logbook_catch = .data$sum_catch_mt) |>
      dplyr::summarise(
        logbook_catch = sum(logbook_catch),
        .by = c(.data$SP_CODE, .data$FLAG_CODE, .data$GEAR_CODE, .data$YY)
      )

    joined_catch <-
      ace_catch |>
      dplyr::select(-.data$data_source) |>
      dplyr::full_join(logbook_catch) |>
      dplyr::mutate(
        ace_catch = tidyr::replace_na(ace_catch, 0),
        logbook_catch = tidyr::replace_na(logbook_catch, 0)
      )

    if (group_species) {
      joined_catch_spp <-
        joined_catch |>
        dplyr::summarise(
          logbook_catch = sum(logbook_catch),
          ace_catch = sum(ace_catch),
          .by = -c(.data$SP_CODE, ace_catch, logbook_catch)
        )
    } else {
      joined_catch_spp <- joined_catch
    }

    coverage_output <-
      joined_catch_spp |>
      dplyr::mutate(
        coverage = dplyr::case_when(
          ace_catch > 0 & logbook_catch > 0 ~ (logbook_catch / ace_catch),
          ace_catch == 0 & logbook_catch > 0 ~ NA,
          ace_catch > 0 & logbook_catch == 0 ~ 0,
          .default = NA
        )
      )

    nrow_low_ace <-
      coverage_output |>
      dplyr::filter(logbook_catch > ace_catch) |>
      nrow()

    if (nrow_low_ace > 0) {
      warning(
        glue::glue(
          "{nrow_low_ace} rows recorded logbook catches greater than ACE catches."
        ),
        call. = FALSE
      )
    }

    # final_coverage <-
    #   coverage_output |>
    #   dplyr::mutate(coverage = dplyr::if_else(coverage > 1, 1, coverage))

    return(coverage_output)
  }
