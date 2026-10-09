# Extract MD2 shape file for a given model number or species

Queries region boundary polygons for a given model from the MD2 database
and layers them onto an existing Pacific map (typically from
[`plot_pacific()`](https://pacificcommunity.github.io/fishextract/reference/plot_pacific.md)),
coloured by `region_id`.

## Usage

``` r
get_md2_shp(model_id = NULL, species = NULL, crs = 4326)
```

## Arguments

- model_id:

  Optional (unless `species` not specified). MD2 `model_id` number

- species:

  Optional (unless `model_id` not specified). Species used to identify
  `model_id`.

- crs:

  Coordinate reference system of the `lon`/`lat` values, passed to
  [`sf::st_sfc()`](https://r-spatial.github.io/sf/reference/sfc.html).
  Defaults to `4326` (WGS84). Ignored when `points` is an `sf`, `sfc` or
  `bbox` object, which carry their own CRS.

## Value

A ggplot object with region boundary polygons added.
