# Aggregate catch and effort by assessment region

Assigns gridded catch and effort data to assessment regions and sums
them by region, species and gear. Regions with no data for a given
species and gear combination are retained with zeros, so the output is a
complete grid.

## Usage

``` r
catcheffort_byregion(
  catcheffort,
  assessment_region,
  crs = 4326,
  show_plot = FALSE,
  ...
)
```

## Arguments

- catcheffort:

  A data frame of gridded catch and effort, such as the output of
  [`get_aggregated_catcheffort()`](https://pacificcommunity.github.io/fishextract/reference/get_aggregated_catcheffort.md).
  Must contain the columns `lond`, `latd`, `SP_CODE`, `GEAR_CODE`,
  `sum_catch_mt`, `hhooks`, `VESS_N`, `days` and `sets`.

- assessment_region:

  An `sf` object of assessment region polygons with a `region_id`
  column, such as the output of
  [`as_region()`](https://pacificcommunity.github.io/fishextract/reference/as_region.md)
  or
  [`get_md2_shp()`](https://pacificcommunity.github.io/fishextract/reference/get_md2_shp.md).

- crs:

  Coordinate reference system of `catcheffort` coordinates, passed to
  [`sf::st_as_sf()`](https://r-spatial.github.io/sf/reference/st_as_sf.html).
  Defaults to `4326` (WGS 84).

- show_plot:

  Logical. If `TRUE`, prints a map of the aggregated catch overlaid with
  the assessment regions before aggregating. Defaults to `FALSE`.

- ...:

  Additional arguments passed to
  [`plot_aggregated_catch()`](https://pacificcommunity.github.io/fishextract/reference/plot_aggregated_catch.md)
  when `show_plot = TRUE`, for example `facet_by = GEAR_CODE`. Ignored
  otherwise.

## Value

A tibble with one row per combination of `region_id`, `SP_CODE` and
`GEAR_CODE`, containing the summed `sum_catch_mt`, `hhooks`, `VESS_N`,
`days` and `sets`. Combinations with no data are filled with `0`.

## Details

Grid cells are assigned to regions using their centre point. The cell
size is taken as the smallest gap between unique `latd` values, and each
coordinate is shifted by half that gap (`lond`/`latd` are assumed to be
the south-west corner of each cell, and the same resolution is assumed
for longitude). Because centres sit away from the cell edges, cells are
not lost when a region boundary lies on a grid line (for example, at
150°). Region boundaries that cut through the middle of a cell will
assign it to whichever region contains its centre.

Cells are matched with
[`sf::st_within()`](https://r-spatial.github.io/sf/reference/geos_binary_pred.html),
so any cell centre falling exactly on a region boundary, or outside
every region, is dropped.

`VESS_N` is summed across cells, so vessels operating in more than one
cell are counted more than once. Treat it as vessel-cell counts rather
than unique vessels.

## See also

[`get_aggregated_catcheffort()`](https://pacificcommunity.github.io/fishextract/reference/get_aggregated_catcheffort.md),
[`as_region()`](https://pacificcommunity.github.io/fishextract/reference/as_region.md),
[`get_md2_shp()`](https://pacificcommunity.github.io/fishextract/reference/get_md2_shp.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Define a simple two-region assessment area from vertices
bb <- tibble::tribble(
  ~region_id , ~lon , ~lat ,
  "1"        ,  110 ,   -0 ,
  "1"        ,  110 ,   20 ,
  "1"        ,  150 ,   20 ,
  "1"        ,  150 ,    0 ,
  "2"        ,  160 ,   -0 ,
  "2"        ,  160 ,   -5 ,
  "2"        ,  190 ,   -5 ,
  "2"        ,  190 ,  -10 ,
  "2"        ,  200 ,  -10 ,
  "2"        ,  200 ,    0
)

x <- get_aggregated_catcheffort(
  flag = "KI",
  year = 2020:2025,
  species = "YFT",
  gear = c("L", "S")
)
y <- as_region(bb)
# or get regions from MD2 by model_id or species:
# y <- get_md2_shp(model_id = 130)

# Aggregate and plot, faceting the map by gear
catcheffort_byregion(x, y, show_plot = TRUE, facet_by = GEAR_CODE)
} # }
```
