# Plot a Pacific-centred base map

Draws the world coastline using `ggplot2::map_data("world2")`

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
  eez_countries = NULL
)
```

## Value

A `ggplot` object.
