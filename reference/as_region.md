# Create assessment regions from vertices or spatial objects

Converts a table of vertices (or an existing spatial object) into an
`sf` object with one polygon per region. Rings are closed automatically
and each polygon is checked for self-intersections.

## Usage

``` r
as_region(points, group = "region_id", crs = 4326)
```

## Arguments

- points:

  One of:

  - A data frame with `lon` and `lat` columns, with rows ordered around
    the perimeter of each region. Rows are split into separate polygons
    by the `group` column.

  - An `sf` object, returned unchanged.

  - An `sfc` or `bbox` object, returned as a single region called
    `"area"`.

- group:

  Character. Name of the column in `points` that identifies separate
  regions. If the column is not present, all rows are treated as one
  region called `"area"`. Defaults to `"region_id"`.

- crs:

  Coordinate reference system of the `lon`/`lat` values, passed to
  [`sf::st_sfc()`](https://r-spatial.github.io/sf/reference/sfc.html).
  Defaults to `4326` (WGS84). Ignored when `points` is an `sf`, `sfc` or
  `bbox` object, which carry their own CRS.

## Value

An `sf` object with one row per region, a `region_id` column and a
polygon `geometry` column. Aborts if any polygon has fewer than three
vertices or is self-intersecting.

## Examples

``` r
areas <- tibble::tribble(
  ~region_id, ~lon, ~lat,
  "1",         140,  -40,
  "1",         155,  -38,
  "1",         152,  -25,
  "1",         141,  -28,
  "2",         160,  -20,
  "2",         165,  -20,
  "2",         163,  -15
)

# Two regions, split by region_id
as_region(areas)
#> Simple feature collection with 2 features and 1 field
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 140 ymin: -40 xmax: 165 ymax: -15
#> Geodetic CRS:  WGS 84
#>   region_id                       geometry
#> 1         1 POLYGON ((140 -40, 155 -38,...
#> 2         2 POLYGON ((160 -20, 165 -20,...

# From a bounding box
as_region(sf::st_bbox(c(xmin = 140, ymin = -40, xmax = 155, ymax = -25), crs = 4326))
#> Simple feature collection with 1 feature and 1 field
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 140 ymin: -40 xmax: 155 ymax: -25
#> Geodetic CRS:  WGS 84
#>   region_id                       geometry
#> 1      area POLYGON ((140 -40, 155 -40,...
```
