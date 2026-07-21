#' @export
db_list_tables <- function(schema) {
  db_connection() |>
    DBI::dbListTables(schema = schema)
}
