#' Preview rows from a database table
#'
#' Builds and executes a `SELECT TOP` query against a schema-qualified
#' table, returning a quick preview of its contents.
#'
#' @param schema Character. Name of the database schema.
#' @param table Character. Name of the table to preview.
#' @param nrow Integer. Number of rows to return. Set to `NULL` to return
#'   all rows (omits the `TOP` clause). Defaults to `10`.
#'
#' @return A data frame (or tibble, depending on `db_query()`) containing
#'   the queried rows.
#'
#' @examples
#' \dontrun{
#' db_show_table(schema = "log", table = "trips_ll")
#' db_show_table(schema = "ref", table = "entities", n_rows = NULL)
#' }
#'
#' @export
db_show_table <- function(schema, table, n_rows = 10) {
  if (!table %in% db_list_tables(schema = schema)) {
    stop(glue::glue("table ('{table}') not in schema ('{schema}')"))
  }

  nrow_clause <- if (!is.null(n_rows)) {
    glue::glue("TOP {n_rows}")
  } else {
    ""
  }

  glue::glue(
    "
  SELECT {nrow_clause} *
  FROM {schema}.{table}
  "
  ) |>
    db_query()
}
