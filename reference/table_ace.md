# Tabulate ACE catch by year and a grouping variable

Takes the output of
[`get_ace()`](https://pacificcommunity.github.io/fishextract/reference/get_ace.md),
aggregates total catch (t) by `YY` and a chosen grouping column, then
pivots the grouping column out wide so each year is a row and each group
(species, gear, ocean, flag, etc.) is a column. Where `pivot_by` is
`GEAR_CODE` or `SP_CODE`, column names use full names rather than raw
codes.

## Usage

``` r
table_ace(
  data,
  pivot_by,
  totals = TRUE,
  round_to = 1,
  abbreviate_flags = FALSE
)
```

## Arguments

- data:

  A tibble as returned by
  [`get_ace()`](https://pacificcommunity.github.io/fishextract/reference/get_ace.md),
  containing at least `YY` and `sum_catch_mt`.

- pivot_by:

  Bare column name to pivot wide (e.g. `SP_CODE`, `GEAR_CODE`,
  `OCEAN_CODE`, `FLAG_CODE`).

- totals:

  Logical. Add a `Total` row and column? Defaults to `TRUE`.

- round_to:

  Numeric. Round catch values to the nearest this many units before
  display. Defaults to `1`.

- abbreviate_flags:

  Logical. If `pivot_by` is `FLAG_CODE`, should column names use
  abbreviated country names (e.g. "FSM") rather than full names?
  Defaults to `FALSE`.

## Value

A tibble, one row per `YY`, one column per level of `pivot_by` (plus
`Total` if `totals = TRUE`).

## Examples

``` r
if (FALSE) { # \dontrun{
ace_output <- get_ace(ocean = "WX", species = c("YFT", "SKJ"))

table_ace(ace_output, pivot_by = SP_CODE)
table_ace(ace_output, pivot_by = GEAR_CODE, totals = FALSE)
} # }
```
