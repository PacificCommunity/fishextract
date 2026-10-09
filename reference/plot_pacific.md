# Plot a Pacific-centred base map

Draws the world coastline using the Pacific-centred `"world2"` map from
the `maps` package, optionally overlaid with Exclusive Economic Zone
(EEZ) boundaries.

## Usage

``` r
plot_pacific(
  xlim = c(100, 292),
  ylim = c(-62, 60),
  land_fill = mapping_colours("land"),
  land_outline = mapping_colours("land_outline"),
  water_fill = mapping_colours("water"),
  base_size = 15,
  show_eez = FALSE,
  eez_flag = NULL,
  eez_colour = "blue"
)
```

## Arguments

- xlim:

  Numeric vector of length 2. Longitude limits in degrees east, on a
  0-360 scale (e.g. 180 is the antimeridian and 200 is 160°W). Defaults
  to `c(100, 292)`. If `NULL`, the default is used.

- ylim:

  Numeric vector of length 2. Latitude limits in degrees, with negative
  values south of the equator. Defaults to `c(-62, 60)`. If `NULL`, the
  default is used.

- land_fill:

  Fill colour for land polygons. Defaults to `mapping_colours("land")`.

- land_outline:

  Outline colour for land polygons. Defaults to
  `mapping_colours("land_outline")`.

- water_fill:

  Background colour for the panel, representing water. Defaults to
  `mapping_colours("water")`.

- base_size:

  Base font size in points, passed to
  [`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).
  Defaults to `15`.

- show_eez:

  Logical. If `TRUE`, EEZ boundaries are drawn beneath the land layer.
  Defaults to `FALSE`.

- eez_flag:

  Character vector of flag codes used to select which EEZs are drawn
  when `show_eez = TRUE`. If `NULL` (default), no flag filter is
  applied. Ignored when `show_eez = FALSE`.

- eez_colour:

  Colour of the EEZ boundary lines. Defaults to `"blue"`. Ignored when
  `show_eez = FALSE`.

## Value

A `ggplot` object.
