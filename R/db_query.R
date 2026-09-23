#' Run a query against a given database (default = FISH_MASTER)
#'
#' Executes a SQL query against a given database connection (default = FISH_MASTER) and
#' returns the result as a tibble.
#'
#' @param query A string containing the SQL query to execute.
#' @param ... database and server specific information including the arguments `database` and `server`
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
