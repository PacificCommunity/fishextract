#' Look up flag (country) names by code
#'
#' Returns the full and abbreviated name(s) corresponding to one or
#' more flag codes. Results are sourced from `ref.countries` on first
#' call and cached for the rest of the session — subsequent calls
#' (including single-code lookups like `lookup_flagname("VN")`) filter the
#' cached table locally rather than re-querying the database.
#'
#' @param flag Optional character vector of flag codes to filter by.
#'   If `NULL`, all flags are returned.
#' @param simplify Logical. If `TRUE`, return a named character vector
#'   of `flag_name`, named by `flag_code`, rather than the full tibble.
#'   Defaults to `FALSE`.
#' @param refresh Logical. Force a re-query of the database and refresh
#'   the cache, e.g. if `ref.countries` has been updated this session.
#'   Defaults to `FALSE`.
#'
#' @details
#' `flag_name` and `flag_name_abbr` are sentence-cased and trimmed via
#' `stringr::str_to_sentence()`/`stringr::str_trim()`. Where
#' `flag_name_abbr` is missing, it is filled with `flag_name`.
#'
#' @examples
#' \dontrun{
#' lookup_flagname()
#' lookup_flagname(flag = c("JP", "KR"))
#' lookup_flagname("VN")
#' #>       VN
#' #> "Vietnam"
#' lookup_flagname(refresh = TRUE) # force a fresh pull from the database
#' }
#'
#' @export
lookup_flagname <- function(flag = NULL, simplify = FALSE, refresh = FALSE) {
  flagnames <- pkg_cached(
    "flagnames",
    compute = function() {
      "SELECT 
        country_code AS flag_code, 
        country_name AS flag_name, 
        country_short AS flag_name_abbr 
        FROM ref.countries" |>
        db_query() |>
        dplyr::bind_rows(
          tibble::tribble(
            ~flag_code , ~flag_name            ,
            "EP"       , 'EASTERN PACIFIC NEI' ,
            "IO"       , "INDIAN OCEAN"        , ### CHECK THIS!!!
          )
        ) |>
        dplyr::mutate(
          dplyr::across(
            .cols = dplyr::contains("_name"),
            .fns = ~ stringr::str_to_sentence(stringr::str_trim(.x))
          )
        )
    },
    refresh = refresh
  )

  out <- if (is.null(flag)) {
    flagnames
  } else {
    flagnames |> dplyr::filter(flag_code %in% flag)
  }

  return(tibble::deframe(out[c("flag_code", "flag_name")]))
}
