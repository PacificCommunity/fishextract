#' Summarise the tables and columns in a database
#'
#' Queries `information_schema.columns` to list every schema, table, column
#' and data type available in the database.
#'
#' @param ... Arguments passed on to [db_query()], such as connection details.
#'
#' @returns A tibble with one row per column and the variables `table_schema`,
#'   `table_name`, `column_name` and `data_type`.
#' @export
#' @examplesIf FALSE
#' db_summary()
db_summary <- function(...) {
  db_query(
    query = "SELECT 
      table_schema, 
      table_name, 
      column_name, 
      data_type
    FROM information_schema.columns",
    ...
  )
}
