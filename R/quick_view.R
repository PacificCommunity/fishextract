quick_view <- function(schema = NULL, table = NULL, nrow = 10) {
  nrow_clause <- if (!is.null(nrow)) {
    glue::glue("TOP {nrow}")
  } else {
    ""
  }

  glue::glue(
    "
  SELECT {nrow_clause} *
  FROM {schema}.{table}
  "
  ) |>
    .db_query()
}
