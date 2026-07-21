#' Connect to the database
#'
#' Opens a connection to the SQL Server database via ODBC.
#' Accepts either a pre-built connection string, or individual connection
#' parameters which are assembled into one automatically.
#'
#' @param connection_string A complete ODBC connection string. If supplied,
#'   this is used as-is and all other arguments are ignored. Defaults to
#'   `NULL`, in which case a string is built from `driver`, `server` and
#'   `database`.
#' @param driver ODBC driver name. Defaults to `"SQL Server"`, a generic
#'   driver name available on most platforms without needing a specific
#'   driver version installed.
#' @param server Server hostname. Defaults to `"noufamesql04"`.
#' @param database Database name. Defaults to `"FISH_MASTER"`.
#' @param ... Additional named arguments passed on to [DBI::dbConnect()].
#'
#' @return A `DBIConnection` object representing the open connection.
#'
#' @details
#' Callers are responsible for disconnecting the connection (e.g. with
#' [DBI::dbDisconnect()]) once finished, or wrapping usage with
#' `on.exit(DBI::dbDisconnect(con))`.
#'
#' @examples
#' \dontrun{
#' # Default: built from driver/server/database
#' con <- db_connection()
#'
#' # Fully custom connection string
#' con <- db_connection(
#'   connection_string = "driver=SQL Server;server=noufamesql04;database=FISH_MASTER"
#' )
#'
#' DBI::dbDisconnect(con)
#' }
#'
#' @importFrom glue glue
#' @importFrom odbc odbc
#' @importFrom DBI dbConnect dbDisconnect
#'
#' @export
db_connection <- function(
  connection_string = NULL,
  driver = "SQL Server",
  server = "noufamesql04",
  database = "FISH_MASTER",
  ...
) {
  if (is.null(connection_string)) {
    connection_string <- glue::glue(
      "driver={driver};server={server};database={database}"
    )
  }

  DBI::dbConnect(
    drv = odbc::odbc(),
    .connection_string = connection_string,
    ...
  )
}
