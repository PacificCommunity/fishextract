# Count vessels by ocean, flag, gear, and year

Queries the `ace.A_ACE` table for vessel counts, optionally filtered by
ocean, flag state, gear type, and/or year. Filters are built via
`.sql_filter()`, so any parameter left as `NULL` is excluded from the
`WHERE` clause rather than matched literally.

## Usage

``` r
get_n_vessels(
  ocean = "WX",
  flag = NULL,
  gear = NULL,
  year = NULL,
  group_species = FALSE,
  group_flags = FALSE,
  group_gears = FALSE,
  include_size_classes = FALSE
)
```

## Arguments

- ocean:

  Character. Ocean code to filter on. `NULL` (default) returns all
  oceans.

- flag:

  Character. Flag code to filter on. `NULL` (default) returns all flags.

- gear:

  Character. Gear code to filter on. `NULL` (default) returns all gears.

- year:

  Integer. Year to filter on. `NULL` (default) returns all years.

## Value

A data frame (or tibble, depending on
[`db_query()`](https://pacificcommunity.github.io/fishextract/reference/db_query.md))
with one row per ocean/flag/gear/year combination, giving `ocean_code`,
`flag_code`, `gear_code`, `year`, and `n_vessels`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_n_vessels(ocean = "ATL", year = 2023)
get_n_vessels(flag = "ESP", gear = "PS")
} # }
```
