# Calculate logbook reporting coverage against ACE catch estimates

Compares logbook-reported catch against ACE (aggregated catch estimate)
catch for the same flag/gear/species/year strata, and calculates the
proportional shortfall of logbook catch relative to ACE catch.

## Usage

``` r
calculate_logbook_coverage(
  in_wcpfc = TRUE,
  year = NULL,
  flag = NULL,
  gear = NULL,
  species = NULL,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  group_species = TRUE,
  ...
)
```

## Arguments

- in_wcpfc:

  Optional logical. If not `NULL`, restricts `sum_ace()` to the `"WX"`
  ocean code and is passed through to `logbook_catch()` as its
  WCPFC-area filter; if `NULL`, no ocean filter is applied.

- year:

  Optional numeric vector of years to filter by.

- flag:

  Optional character vector of flag codes to filter by.

- gear:

  Optional character vector of gear codes to filter by (passed to
  `logbook_catch()`; `sum_ace()` is not filtered by gear).

- species:

  Optional character vector of species codes to filter by.

- exclude_flag:

  Optional character vector of flag codes to exclude. Defaults to
  `NULL`.

- exclude_gear:

  Optional character vector of gear codes to exclude. Defaults to
  `NULL`.

- exclude_species:

  Optional character vector of species codes to exclude. Defaults to
  `NULL`.

- group_species:

  Logical. If `TRUE`, catch is summed across all species within each
  remaining grouping (i.e. `SP_CODE` is dropped before summarising).
  Defaults to `FALSE`.

- ...:

  optional arguments that get passed to
  [`db_query()`](https://pacificcommunity.github.io/fishextract/reference/db_query.md)
  such as the database server and connection

## Value

A tibble of `ace_catch`, `logbook_catch`, and `coverage`
(`(ace_catch - logbook_catch) / ace_catch`) by flag, year, species
(unless `group_species = TRUE`), and gear.

## Details

`ace_catch` is obtained via
[`get_ace()`](https://pacificcommunity.github.io/fishextract/reference/get_ace.md)
and `logbook_catch` via
[`get_logbook_catch()`](https://pacificcommunity.github.io/fishextract/reference/get_logbook_catch.md),
using the same flag/gear/species/year filters. The two are
`full_join()`ed so that strata present in only one source are retained,
with missing catch values filled to zero via
[`tidyr::replace_na()`](https://tidyr.tidyverse.org/reference/replace_na.html).
If `group_species = TRUE`, `logbook_catch` is re-summed across species
(`SP_CODE` dropped from the grouping); a `coverage` column is then
calculated as the proportional difference between ACE and logbook catch.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_logbook_coverage(in_wcpfc = TRUE)
calculate_logbook_coverage(in_wcpfc = TRUE, group_species = TRUE)
} # }
```
