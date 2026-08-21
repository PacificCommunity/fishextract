#' @export
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
