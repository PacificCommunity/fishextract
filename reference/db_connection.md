# Connect to the database

Opens a connection to the SQL Server database via ODBC. Accepts either a
pre-built connection string, or individual connection parameters which
are assembled into one automatically.

## Usage

``` r
db_connection(
  connection_string = NULL,
  driver = "SQL Server",
  server = "noufamesql04",
  database = "FISH_MASTER",
  ...
)
```

## Arguments

- connection_string:

  A complete ODBC connection string. If supplied, this is used as-is and
  all other arguments are ignored. Defaults to `NULL`, in which case a
  string is built from `driver`, `server` and `database`.

- driver:

  ODBC driver name. Defaults to `"SQL Server"`, a generic driver name
  available on most platforms without needing a specific driver version
  installed.

- server:

  Server hostname. Defaults to `"noufamesql04"`.

- database:

  Database name. Defaults to `"FISH_MASTER"`.

- ...:

  Additional named arguments passed on to
  [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

## Value

A `DBIConnection` object representing the open connection.

## Details

Callers are responsible for disconnecting the connection (e.g. with
[`DBI::dbDisconnect()`](https://dbi.r-dbi.org/reference/dbDisconnect.html))
once finished, or wrapping usage with `on.exit(DBI::dbDisconnect(con))`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Default: built from driver/server/database
con <- db_connection()

# Fully custom connection string
con <- db_connection(
  connection_string = "driver=SQL Server;server=noufamesql04;database=FISH_MASTER"
)

DBI::dbDisconnect(con)
} # }
```
