#' Abbreviate country/flag names for compact display
#'
#' Converts full country names into short, conventional forms suitable
#' for tight spaces (facet strips, table columns, legends). Known
#' acronym-style exceptions (e.g. "Federated states of micronesia" to
#' "FSM") are handled via a manual lookup, checked first. Names not in
#' the lookup fall back to general rules: trailing "..., Kingdom of" /
#' "..., Republic of" style suffixes are dropped, and "Islands" is
#' abbreviated to "Is.". Anything matching neither is returned trimmed
#' but otherwise unchanged.
#'
#' @param country_name Character vector of country names, as returned
#'   by [lookup_flagname()].
#'
#' @return Character vector of shortened names, same length as input.
#'
#' @examples
#' abbreviate_flagname(c(
#'   "Federated states of micronesia",
#'   "Tonga, kingdom of",
#'   "Marshall islands"
#' ))
#' #> [1] "FSM"          "Tonga"        "Marshall Is."
#'
#' @export
abbreviate_flagname <- function(country_name) {
  # don't have to worry about case on left-hand-side
  overrides <- c(
    "federated states of micronesia" = "FSM",
    "united states of america" = "USA",
    "papua new guinea" = "PNG",
    "chinese taipei" = "Chinese Taipei"
  )

  key <- country_name |> stringr::str_to_lower() |> stringr::str_trim()

  general <-
    country_name |>
    stringr::str_remove(
      stringr::regex(
        ",?\\s*(kingdom|republic|state|federation|territory|province)\\s+of\\b",
        ignore_case = TRUE
      )
    ) |>
    stringr::str_replace(
      stringr::regex("\\bislands\\b", ignore_case = TRUE),
      "Is."
    ) |>
    stringr::str_trim()

  dplyr::coalesce(unname(overrides[key]), general)
}
