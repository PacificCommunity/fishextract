# Retrieve logbook catch data

Queries logbook catch-and-effort tables for one or more gear types and
returns total catch (metric tonnes) summarised by flag, year, species
and gear.

## Usage

``` r
get_logbook_catch(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  fleet = NULL,
  eez = NULL,
  gear = c("P", "S", "L", "T", "O"),
  species = NULL,
  exclude_flag = NULL,
  exclude_species = NULL,
  show_sql = FALSE,
  ...
)
```

## Arguments

- in_wcpfc:

  Optional filter passed to `.sql_filter()` restricting records to those
  inside (or outside) the WCPFC Convention Area.

- year:

  Optional numeric vector of years to filter by.

- flag:

  Optional character vector of flag codes to filter by.

- fleet:

  Optional character vector of fleet codes to filter by.

- eez:

  Optional character vector of eez codes to filter by.

- gear:

  Character vector of gear codes to query. One or more of `"P"` (purse
  seine), `"S"` (pole-and-line), `"L"` (longline), or `"T"` (troll).
  Defaults to all four.

- species:

  Optional character vector of species codes to filter by.

- exclude_flag:

  Optional character vector of flag codes to exclude. Defaults to
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

A tibble with one row per flag/year/species/gear combination,
containing:

- FLAG_CODE:

  Flag code.

- YY:

  Year.

- SP_CODE:

  Species code.

- sp_mt:

  Catch, in metric tonnes.

- GEAR_CODE:

  Gear code (`"P"`, `"S"`, `"L"`, or `"T"`).

## Details

For each requested gear, catch is pulled by joining `log.trips_*` -\>
`log.sets_*` -\> `log.catch_*` (table suffix set by `gear_suffix`),
restricted to vessel instances active over the trip period (via
`ref.vessel_instances`). Longline (`"L"`) catch is queried and summed in
kilograms (`sp_kg`, including discards) since it is recorded at that
resolution; all other gears are summed directly in tonnes (`sp_mt`).
After all gears are queried and row-bound, any `sp_kg` totals are
converted to tonnes and coalesced into `sp_mt`, and the now-redundant
`sp_kg` column is dropped.

## Note

`convert_catch_to_mt()` is defined inside the function but is not
currently called anywhere in the body — the kg-to-tonnes conversion for
longline catch is instead handled directly in the final
[`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
step. Left in place here as-is; flag for removal or wiring in if that
was the intent.

## Examples

``` r
if (FALSE) { # \dontrun{
# All gears, all flags/species/years
get_logbook_catch()

# Purse seine and longline catch for one flag, 2020-2023
get_logbook_catch(flag = "FJ", gear = c("P", "L"), year = 2020:2023)
} # }
```
