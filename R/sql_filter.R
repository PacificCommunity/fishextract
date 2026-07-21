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
.sql_filter <- function(column, x) {
  if (is.null(x)) {
    return("1=1")
  }
  glue::glue("{column} in {.Rstr_to_SQLstring(x)}")
}
