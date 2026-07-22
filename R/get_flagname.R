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
