# Summarise ACE catch by ocean, flag, gear, species and year

Queries the ACE database and returns total catch (in metric tonnes),
summed by ocean, flag, gear, species and year. Any filter left as `NULL`
(the default) is not applied, so all values for that field are included.

## Usage

``` r
get_ace(
  ocean = "WX",
  year = NULL,
  flag = NULL,
  fleet = NULL,
  gear = NULL,
  species = NULL,
  eez = NULL,
  in_archipelagic = NULL,
  exclude_flag = NULL,
  exclude_fleet = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  exclude_eez = NULL,
  group_flags = FALSE,
  group_fleets = TRUE,
  group_gears = FALSE,
  group_species = FALSE,
  ungroup_eez = FALSE,
  show_sql = FALSE
)
```

## Arguments

- ocean:

  A character vector of ocean codes to filter on (e.g. `"WX"`), or
  `NULL` (default) to include all oceans.

- year:

  A numeric or character vector of years to filter on (e.g.
  `2024:2025`), or `NULL` (default) to include all years.

- flag:

  A character vector of flag codes to filter on (e.g. `c("ID", "VN")`),
  or `NULL` (default) to include all flags.

- fleet:

  A character vector of fleet codes to filter by.

- gear:

  A character vector of gear codes to filter on (e.g. `"L"` for
  longline), or `NULL` (default) to include all gears.

- species:

  A character vector of species codes to filter on (e.g.
  `c("YFT", "SKJ")`), or `NULL` (default) to include all species.

- eez:

  A character vector of country codes to filter the EEZ(s) where the
  fishing has occured.

- in_archipelagic:

  Logical. If `TRUE` filter for archipelagic waters only.

- exclude_flag:

  Optional character vector of flag codes to exclude. Defaults to
  `NULL`.

- exclude_fleet:

  Optional character vector of fleet codes to exclude. Defaults to
  `NULL`.

- exclude_gear:

  Optional character vector of gear codes to exclude. Defaults to
  `NULL`.

- exclude_species:

  Optional character vector of species codes to exclude. Defaults to
  `NULL`.

- exclude_eez:

  Optional character vector of EEZ codes to exclude. Defaults to `NULL`.

- group_flags:

  Logical. If `TRUE`, return combined catch across all flags specified.
  Default = `FALSE`.

- group_fleets:

  Logical. If `TRUE`, return combined catch across all fleets specified.
  Default = `TRUE`.

- group_gears:

  Logical. If `TRUE`, return combined catch across all gears specified.
  Default = `FALSE`.

- group_species:

  Logical. If `TRUE`, return combined catch across all species
  specified. Default = `FALSE`.

- ungroup_eez:

  Logical. If `TRUE`, ACE will be ungrouped into the EEZs where the
  catch occured. Default = `FALSE`.

- show_sql:

  Logical. If `TRUE`, prints the SQL code used to extract the data.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns `OCEAN_CODE`, `FLAG_CODE`, `GEAR_CODE`, `SP_CODE`, `YY` and
`sum_catch_mt`, one row per unique combination of ocean, flag, gear,
species and year present in the (filtered) data. *Note*: if any of the
grouping arguements (e.g., `group_species` or `group_flags`) are set to
`TRUE`, these columns will be omitted from the output tibble.

## Details

Assumes `FLAG_CODE` is a column on `ace.A_ACE`. If it instead lives on
`ace.A_ACE_CATCH` or another joined table, update the SQL accordingly.

## Examples

``` r
if (FALSE) { # \dontrun{
# Filter on everything
get_ace(
  ocean   = "WX",
  flag    = c("ID", "VN"),
  gear    = "L",
  species = c("YFT", "SKJ"),
  year    = 2024:2025
)

# No filters at all — all oceans, flags, gears, species and years
get_ace()
} # }
```
