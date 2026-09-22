# Add shaded region(s) to a Pacific map

Shades the area of one or more named regions (see
`.mapping_polygons_lookup`). When `type` has length \> 1, their union is
shaded as a single polygon — use this for regions that share a colour
(e.g. `c("nx", "sx")`).

## Usage

``` r
add_shading(plot, type, fill = "red", alpha = 0.2)
```

## Arguments

- plot:

  A ggplot object, as built by
  [`plot_pacific()`](https://pacificcommunity.github.io/fishextract/reference/plot_pacific.md).

- type:

  Character vector of region name(s) to shade.

- fill:

  Fill colour.

- alpha:

  Fill transparency.
