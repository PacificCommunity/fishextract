#' Convert a vector to a SQL string
#'
#' Sorts a character vector and collapses it into a single string formatted
#' as a comma-separated, quoted list suitable for use in a SQL `IN` clause.
#'
#' @param x A character vector of values to include in the SQL string.
#'
#' @return A single string of the form `"('a', 'b', 'c')"`, with elements
#'   wrapped in single quotes.
#'
#' @examples
#' .Rstr_to_SQLstring(c("YFT", "BET", "SKJ"))
#' # "('YFT', 'BET', 'SKJ')"
#'
#' @noRd
.Rstr_to_SQLstring <- function(x) {
  paste0("('", paste(x, collapse = "', '"), "')")
}
