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
    .db_query()
}
