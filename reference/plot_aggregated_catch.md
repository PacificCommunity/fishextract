# Plot aggregated catch as scatterpies on a Pacific basemap

Aggregates catch data by location (and optionally by colour and facet
variables), then plots each location as a pie chart ("scatterpie") whose
radius is proportional to total catch and whose wedges show the
proportional breakdown of `colour_by`. A size legend is added
automatically, and the plot can optionally be faceted.

## Usage

``` r
plot_aggregated_catch(
  aggregated_data = NULL,
  colour_by = NULL,
  facet_by = NULL,
  pie_radius = NULL,
  alpha = 1,
  xlim = NULL,
  ylim = NULL,
  latlon_offset = NULL,
  lim_buffer = 0.1,
  water_fill = "white",
  ...
)
```

## Arguments

- aggregated_data:

  A data frame of catch data with, at minimum, `latd`, `lond` and
  `sum_catch_mt` columns. If `NULL` (the default), data are pulled via
  [`calculate_logbook_coverage()`](https://pacificcommunity.github.io/fishextract/reference/calculate_logbook_coverage.md),
  with `...` passed through.

- colour_by:

  \<[`data-masked`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  Column used to fill and split each pie into wedges (e.g. species
  code). Set to `NULL` to omit colour splitting and plot single-colour
  pies.

- facet_by:

  \<[`data-masked`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  Optional column to facet the plot by (e.g. year, gear type). Defaults
  to `NULL` (no faceting).

- pie_radius:

  Numeric scalar; multiplier applied to pie and legend circle radii.
  Defaults to `1`.

- alpha:

  Numeric scalar; fill transparency for the pie wedges. Defaults to `1`.

- xlim:

  Numeric vector of length 2 giving longitude limits (0–360 convention).
  Defaults to `c(100, 292)`.

- ylim:

  Numeric vector of length 2 giving latitude limits. Defaults to
  `c(-62, 60)`.

- ...:

  Additional arguments passed to
  [`calculate_logbook_coverage()`](https://pacificcommunity.github.io/fishextract/reference/calculate_logbook_coverage.md)
  when `aggregated_data` is `NULL`.

## Value

A `ggplot` object.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_aggregated_catch(catch_data, colour_by = SP_CODE)
plot_aggregated_catch(catch_data, colour_by = SP_CODE, facet_by = yy)
plot_aggregated_catch(colour_by = SP_CODE, year = 2020:2023)
} # }
```
