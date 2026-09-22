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
  gear = NULL,
  species = NULL,
  eez = NULL,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL,
  exclude_eez = NULL,
  group_flags = FALSE,
  group_gears = FALSE,
  group_species = FALSE,
  ungroup_eez = FALSE
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

- gear:

  A character vector of gear codes to filter on (e.g. `"L"` for
  longline), or `NULL` (default) to include all gears.

- species:

  A character vector of species codes to filter on (e.g.
  `c("YFT", "SKJ")`), or `NULL` (default) to include all species.

- group_species:

  Boolean. If TRUE, return combined catch across all species specified

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
