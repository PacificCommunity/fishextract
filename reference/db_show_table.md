# Preview rows from a database table

Builds and executes a `SELECT TOP` query against a schema-qualified
table, returning a quick preview of its contents.

## Usage

``` r
db_show_table(schema, table, n_rows = 10)
```

## Arguments

- schema:

  Character. Name of the database schema.

- table:

  Character. Name of the table to preview.

- nrow:

  Integer. Number of rows to return. Set to `NULL` to return all rows
  (omits the `TOP` clause). Defaults to `10`.

## Value

A data frame (or tibble, depending on
[`db_query()`](https://pacificcommunity.github.io/fishextract/reference/db_query.md))
containing the queried rows.

## Examples

``` r
if (FALSE) { # \dontrun{
db_show_table(schema = "log", table = "trips_ll")
db_show_table(schema = "ref", table = "entities", n_rows = NULL)
} # }
```
