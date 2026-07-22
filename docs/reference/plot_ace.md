# Plot ACE catch trends by year

Takes the output of
[`sum_ace()`](https://freddieh.github.io/fishextract/reference/sum_ace.md)
and plots total catch (t) as a line against year, optionally coloured
and/or faceted by another grouping column still present in the data
(e.g. `OCEAN_CODE`, `FLAG_CODE`, `GEAR_CODE`, `SP_CODE`). Data are
re-aggregated internally over `YY`, `colour_by` and `facet_by` so lines
are always clean, regardless of which other grouping columns remain in
`data`.

## Usage

``` r
plot_ace(data, colour_by = NULL, facet_by = NULL, facet_scales = "fixed")
```

## Arguments

- data:

  A tibble as returned by
  [`sum_ace()`](https://freddieh.github.io/fishextract/reference/sum_ace.md),
  containing at least `YY` and `sum_catch_mt`.

- colour_by:

  Optional. Bare column name to colour lines by (e.g. `SP_CODE`).
  Defaults to `NULL` (single line, no colour grouping).

- facet_by:

  Optional. Bare column name to facet by (e.g. `OCEAN_CODE`). Defaults
  to `NULL` (no facetting).

- facet_scales:

  Passed to
  [`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)'s
  `scales` argument when `facet_by` is supplied. Defaults to `"fixed"`.

## Value

A
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Examples

``` r
if (FALSE) { # \dontrun{
ace_output <- sum_ace(ocean = "WX", species = c("YFT", "SKJ"))

# Single line, total catch by year
plot_ace(ace_output)

# Coloured by species
plot_ace(ace_output, colour_by = SP_CODE)

# Coloured by species, faceted by ocean, free y-scales per panel
plot_ace(ace_output, colour_by = SP_CODE, facet_by = OCEAN_CODE, facet_scales = "free_y")
} # }
```
