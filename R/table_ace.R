#' Tabulate ACE catch by year and a grouping variable
#'
#' Takes the output of [get_ace()], aggregates total catch (t) by `YY`
#' and a chosen grouping column, then pivots the grouping column out
#' wide so each year is a row and each group (species, gear, ocean,
#' flag, etc.) is a column. Where `pivot_by` is `GEAR_CODE` or
#' `SP_CODE`, column names use full names rather than raw codes.
#'
#' @param data A tibble as returned by [get_ace()], containing at least
#'   `YY` and `sum_catch_mt`.
#' @param pivot_by Bare column name to pivot wide (e.g. `SP_CODE`,
#'   `GEAR_CODE`, `OCEAN_CODE`, `FLAG_CODE`).
#' @param totals Logical. Add a `Total` row and column? Defaults to
#'   `TRUE`.
#' @param round_to Numeric. Round catch values to the nearest this many
#'   units before display. Defaults to `1`.
#' @param abbreviate_flags Logical. If `pivot_by` is `FLAG_CODE`,
#'   should column names use abbreviated country names (e.g. "FSM")
#'   rather than full names? Defaults to `FALSE`.
#'
#' @return A tibble, one row per `YY`, one column per level of
#'   `pivot_by` (plus `Total` if `totals = TRUE`).
#'
#' @examples
#' \dontrun{
#' ace_output <- get_ace(ocean = "WX", species = c("YFT", "SKJ"))
#'
#' table_ace(ace_output, pivot_by = SP_CODE)
#' table_ace(ace_output, pivot_by = GEAR_CODE, totals = FALSE)
#' }
#'
#' @importFrom rlang enquo as_name
#'
#' @export
table_ace <- function(
  data,
  pivot_by,
  totals = TRUE,
  round_to = 1,
  abbreviate_flags = FALSE
) {
  pivot_by <- rlang::enquo(pivot_by)
  pivot_name <- rlang::as_name(pivot_by)
  pivot_lookup <- pkg_label_lookup(
    pivot_name,
    abbreviate_flags = abbreviate_flags
  )

  table_data <-
    data |>
    dplyr::summarise(
      sum_catch_mt = round(sum(sum_catch_mt) / round_to) * round_to,
      .by = c(YY, !!pivot_by)
    )

  if (!is.null(pivot_lookup)) {
    table_data <- table_data |>
      dplyr::mutate(
        !!pivot_name := dplyr::recode(.data[[pivot_name]], !!!pivot_lookup)
      )
  }

  out <-
    table_data |>
    tidyr::pivot_wider(
      names_from = !!pivot_by,
      values_from = sum_catch_mt,
      values_fill = 0
    ) |>
    dplyr::arrange(YY)

  if (totals) {
    out <- out |>
      dplyr::mutate(Total = rowSums(dplyr::across(-YY))) |>
      dplyr::bind_rows(
        dplyr::summarise(
          out,
          YY = "Total",
          dplyr::across(-YY, sum)
        ) |>
          dplyr::mutate(Total = rowSums(dplyr::across(-YY)))
      )
  }

  out
}
