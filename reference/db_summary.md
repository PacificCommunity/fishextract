# Summarise the tables and columns in a database

Queries `information_schema.columns` to list every schema, table, column
and data type available in the database.

## Usage

``` r
db_summary(...)
```

## Arguments

- ...:

  Arguments passed on to
  [`db_query()`](https://pacificcommunity.github.io/fishextract/reference/db_query.md),
  such as connection details.

## Value

A tibble with one row per column and the variables `table_schema`,
`table_name`, `column_name` and `data_type`.

## Examples

``` r
if (FALSE) {
db_summary()
}
```
