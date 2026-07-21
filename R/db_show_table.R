#' @export
db_show_table <- function(schema, table) {
  if (!table %in% db_list_tables(schema = schema)) {
    stop(glue::glue("table ('{table}') not in schema ('{schema}')"))
  }

  glue::glue(
    "SELECT TOP 10 * 
  FROM {schema}.{table}"
  ) |>
    .db_query()
}
