#' Build a SQL filter clause, or a no-op if no values supplied
#'
#' Returns an `IN` clause for the given column, or `"1=1"` (a filter that
#' always evaluates to `TRUE`) if `x` is `NULL`, so that omitted filters
#' don't restrict the query.
#'
#' @param column A string giving the SQL column name to filter on.
#' @param x A character vector of values to filter on, or `NULL` to skip
#'   filtering on this column.
#'
#' @return A string containing a SQL condition.
#'
#' @importFrom glue glue
#'
#' @noRd
.sql_filter <- function(column, x, exclude = FALSE) {
  if (is.null(x)) {
    return("1 = 1")
  }
  option <- if (exclude) "NOT IN" else "IN"
  glue::glue("{column} {option} {.Rstr_to_SQLstring(x)}")
}

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
