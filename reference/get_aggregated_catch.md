# Pull 5x5 aggregated catch data

Queries `best.A_BEST_AGG_CATCH` (joined to `best.A_BEST_AGG`) for catch
summed by flag, gear, species, year and location, with optional filters
to include/exclude specific flags, gears, species, years, and to
restrict to the WCPFC convention area.

## Usage

``` r
get_aggregated_catch(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  gear = NULL,
  species = NULL,
  group_species = FALSE,
  group_fleets = TRUE,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  show_sql = FALSE,
  ...
)
```

## Arguments

- in_wcpfc:

  Logical; if `TRUE` (the default), restrict results to the WCPFC
  convention area.

- year:

  Optional numeric vector of years (`YY`) to include. Defaults to `NULL`
  (all years).

- flag:

  Optional character vector of flag codes to include. Defaults to `NULL`
  (all flags).

- gear:

  Optional character vector of gear codes to include. Defaults to `NULL`
  (all gears).

- species:

  Optional character vector of species codes to include. Defaults to
  `NULL` (all species).

- group_species:

  Logical. Groups all seleceted species into a single catch value.
  Defaults to `FALSE`.

- exclude_flag:

  Optional character vector of flag codes to exclude. Defaults to
  `NULL`.

- exclude_gear:

  Optional character vector of gear codes to exclude. Defaults to
  `NULL`.

- exclude_species:

  Optional character vector of species codes to exclude. Defaults to
  `NULL`.

- show_sql:

  Logical. If `TRUE`, prints the SQL code used to extract the data.

- ...:

  optional arguments that get passed to
  [`db_query()`](https://pacificcommunity.github.io/fishextract/reference/db_query.md)
  such as the database server and connection

## Value

A data frame with columns `FLAG_CODE`, `GEAR_CODE`, `SP_CODE`, `YY`,
`sum_catch_mt`, `latd`, `lond`, and `data_source`
(`"aggregated_catch"`).

## Examples

``` r
if (FALSE) { # \dontrun{
get_aggregated_catch(year = 2020:2023, species = "SKJ")
get_aggregated_catch(in_wcpfc = FALSE, exclude_gear = "S")
} # }
```
