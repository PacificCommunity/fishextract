# Plot a timeseries from a given data extract

Sums a value column by year (`YY`) and, optionally, by a colouring
and/or faceting variable, then draws the result as a line-and-point
plot. Colours and facet labels are looked up from the package's internal
lookups where available.

## Usage

``` r
plot_timeseries(
  data,
  value_col = NULL,
  colour_by = NULL,
  facet_by = NULL,
  facet_scales = "fixed",
  y_lab = NULL,
  n_breaks = 5
)
```

## Arguments

- data:

  A tibble extracted from one of the `fishextract::get_*` functions.
  Must contain a `YY` column (year) and the column to be plotted.

- value_col:

  \<[`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  Column to sum and plot on the y-axis, supplied unquoted. If `NULL`
  (default), it is detected from `data`: `sum_catch_mt` if present,
  otherwise `n_vessels`. An error is raised if neither is found.

- colour_by:

  \<[`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  Optional column to group and colour the timeseries by, supplied
  unquoted. If `NULL` (default), a single series is drawn.

- facet_by:

  \<[`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  Optional column to split the plot into facets by, supplied unquoted.
  If `NULL` (default), no faceting is applied.

- facet_scales:

  Character string passed to
  [`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html).
  One of `"fixed"` (default), `"free"`, `"free_x"` or `"free_y"`.
  Ignored when `facet_by = NULL`.

- y_lab:

  Character string for the y-axis label. If `NULL` (default),
  `"Catch (mt)"` or `"Number of vessels"` is used when `value_col` is
  detected automatically, otherwise the name of `value_col`.

- n_breaks:

  Integer. Approximate number of x-axis (year) breaks, passed to
  [`base::pretty()`](https://rdrr.io/r/base/pretty.html). Defaults to
  `5`.

## Value

A `ggplot` object.
