# Plot logbook coverage by flag and year

Visualises logbook reporting coverage (as calculated by
[`calculate_logbook_coverage()`](https://pacificcommunity.github.io/fishextract/reference/calculate_logbook_coverage.md))
as a flag x year heatmap, with each tile shaded by coverage and labelled
with the coverage percentage. Facets by gear automatically if more than
one gear is present in the data.

## Usage

``` r
plot_logbook_coverage(coverage_data = NULL, ...)
```

## Arguments

- coverage_data:

  A tibble as returned by
  [`calculate_logbook_coverage()`](https://pacificcommunity.github.io/fishextract/reference/calculate_logbook_coverage.md),
  containing at least `FLAG_CODE`, `YY`, and `coverage` columns (and
  optionally `GEAR_CODE`). If `NULL` (the default),
  [`calculate_logbook_coverage()`](https://pacificcommunity.github.io/fishextract/reference/calculate_logbook_coverage.md)
  is called using `...`.

- ...:

  Additional arguments passed to
  [`calculate_logbook_coverage()`](https://pacificcommunity.github.io/fishextract/reference/calculate_logbook_coverage.md)
  when `coverage_data` is `NULL` (e.g. `in_wcpfc`, `flag`, `gear`,
  `species`, `year`, `group_species`).

- flag_order:

  Optional character vector giving the order flags should appear on the
  y-axis, top to bottom (as per
  `ggplot2::scale_y_discrete(limits = ...)`). Defaults to descending
  mean coverage across the data.

## Value

A `ggplot` object: a tile plot of year (x) by flag (y), filled by
coverage (0-1, `RdYlBu` palette), with each tile labelled with its
coverage as a percentage (or `"X"` where coverage is missing).

## Details

Coverage is expected on a 0-1 scale, where 1 indicates full logbook
coverage relative to ACE catch. Missing coverage (e.g. no ACE catch to
compare against) is plotted as `"X"` rather than a percentage. Label
colour switches between black and white depending on how far a tile's
coverage sits from the midpoint of the colour scale, to keep text
legible against both light and dark fills.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_logbook_coverage(in_wcpfc = TRUE, group_species = TRUE, gear = "L", year = 2004:2025) |>
  plot_logbook_coverage()

# or call calculate_logbook_coverage() implicitly
plot_logbook_coverage(in_wcpfc = TRUE, group_species = TRUE, gear = "S", year = 2004:2025)
} # }
```
