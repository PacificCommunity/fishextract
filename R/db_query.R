#' Run a query against the fish master database
#'
#' Executes a SQL query against the fish master database connection and
#' returns the result as a tibble.
#'
#' @param query A string containing the SQL query to execute.
#'
#' @return A [tibble::tibble()] containing the query result.
#'
#' @examples
#' db_query("SELECT TOP 10 * FROM ace.A_ACE")
#'
#' @importFrom tibble tibble
#' @importFrom DBI dbGetQuery
#'
#' @export
db_query <- function(query, ...) {
  DBI::dbGetQuery(
    conn = db_connection(...),
    statement = query
  ) |>
    tibble::as_tibble()
}
