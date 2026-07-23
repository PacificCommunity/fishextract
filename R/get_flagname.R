#' Look up flag (country) names by code
#'
#' Queries `ref.countries` for the full and abbreviated name(s)
#' corresponding to one or more flag codes.
#'
#' @param flag Optional character vector of flag codes to filter by.
#'   If `NULL`, all flags are returned.
#'
#' @return A tibble of `flag_code`, `flag_name`, and `flag_name_abbr`.
#'
#' @details
#' `flag_name` and `flag_name_abbr` are sentence-cased and trimmed via
#' `stringr::str_to_sentence()`/`stringr::str_trim()`. Where
#' `flag_name_abbr` is missing, it is filled with `flag_name`.
#'
#' @examples
#' \dontrun{
#' get_flagname()
#' get_flagname(flag = c("JP", "KR"))
#' }
#'
#' @export
get_flagname <- function(
  flag = NULL
) {
  glue::glue(
    "
  SELECT  
    country_code AS flag_code, 
    country_name AS flag_name,
    country_short AS flag_name_abbr
  FROM ref.countries
  WHERE {.sql_filter('country_code', flag)}
  "
  ) |>
    .db_query() |>
    dplyr::mutate(
      dplyr::across(
        .cols = dplyr::contains("_name"),
        .fns = ~ stringr::str_to_sentence(stringr::str_trim(.x))
      )
    ) |>
    dplyr::mutate(
      flag_name_abbr = dplyr::case_when(
        is.na(flag_name_abbr) ~ flag_name,
        .default = flag_name_abbr
      )
    )
}
