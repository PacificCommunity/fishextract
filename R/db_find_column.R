#' Find which tables contain a given column
#'
#' Searches `information_schema.columns` across the connected database
#' (optionally restricted to a single schema) to identify every table
#' that contains a column with the specified name.
#'
#' @param column_name Character. Name of the column to search for.
#' @param schema Character. Optional schema name to restrict the search
#'   to. If `NULL` (default), all schemas are searched.
#' @param ... Additional arguments passed to `db_connection()`.
#'
#' @return A data frame (or tibble, depending on `db_query()`) with one
#'   row per matching column, giving `table_schema`, `table_name`,
#'   `column_name`, and `data_type`, ordered by schema and table.
#'
#' @examples
#' \dontrun{
#' find_column(column_name = "species_code")
#' find_column(column_name = "species_code", schema = "dbo")
#' }
#'
#' @export
find_column <- function(
  column_name = NULL,
  schema = NULL,
  ...
) {
  db_con <- db_connection(...)

  schema_clause <- if (!is.null(schema)) {
    glue::glue_sql("AND table_schema = {schema}", .con = db_con)
  } else {
    glue::glue_sql("", .con = db_con)
  }

  glue::glue_sql(
    "
    SELECT 
      table_schema, 
      table_name, 
      column_name, 
      data_type
    FROM information_schema.columns
    WHERE column_name = {column_name}
      {schema_clause}
    ORDER BY 
      table_schema, 
      table_name;
    ",
    .con = db_con
  ) |>
    db_query()
}
