# clean up sql queries to be printed to the screen
#' @noRd
.clean_sql <- function(query) {
  cat("\n ------- START OF STRING -----------------\n")
  query |>
    stringr::str_remove_all("AND 1 = 1\n") |>
    stringr::str_remove_all("  \n") |>
    stringr::str_remove_all("                ") |>
    cat("\n ------- END OF STRING -----------------\n")
}
