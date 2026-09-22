# Add Pacific Statistical Region Lines to a Map

Layers region boundary lines and text annotations onto an existing
Pacific map (typically from
[`plot_pacific()`](https://pacificcommunity.github.io/fishextract/reference/plot_pacific.md)).
The region type is specified by `type`, with each type corresponding to
a particular combination of lines and text annotations.

## Usage

``` r
add_statistical_region(
  plot,
  type,
  colour1 = "red",
  colour2 = "blue",
  shading = FALSE,
  alpha = 0.2
)
```

## Arguments

- plot:

  A ggplot object to add region lines to, as built by
  [`plot_pacific()`](https://pacificcommunity.github.io/fishextract/reference/plot_pacific.md).

- type:

  Character string indicating the region set to add. One of:

  "wcpfc"

  :   Western and Central Pacific Fisheries Commission Convention Area.

  "wcpo_epo"

  :   Western-Central Pacific Ocean and Eastern Pacific Ocean split,
      separated by the 150°W meridian.

  "npo_spo"

  :   North Pacific Ocean and South Pacific Ocean split, separated by
      the equator.

  "nx_sx"

  :   Northern and Southern regions within the WCPFC Convention Area,
      separated by the equator west of the WCPFC boundary.

  "wcpfc_epo"

  :   Overlay of the WCPFC Convention Area and the WCPO/EPO split.
      Colours can be customised using `colour1` and `colour2`.

- colour1:

  Colour used for the first region in map types that support colour
  customisation. Defaults to `"red"`.

- colour2:

  Colour used for the second region in map types that support colour
  customisation. Defaults to `"blue"`.

- shading:

  Logical. If `TRUE`, shade the region(s) relevant to `type`. Where a
  plot type shares one colour across multiple sub-regions (e.g.
  `"nx_sx"`), their union is shaded as a single area.

- alpha:

  Shading transparency. Defaults to `0.2`.

## Value

A ggplot object with the requested region lines (and optional shading)
added.

## Examples

``` r
plot_pacific() |> add_statistical_region("wcpfc")
#> Error in ggplot2::map_data("world2"): The package "maps" is required for `map_data()`.

plot_pacific() |> add_statistical_region("wcpo_epo")
#> Error in ggplot2::map_data("world2"): The package "maps" is required for `map_data()`.

plot_pacific() |> add_statistical_region("npo_spo")
#> Error in ggplot2::map_data("world2"): The package "maps" is required for `map_data()`.

plot_pacific() |> add_statistical_region("nx_sx")
#> Error in ggplot2::map_data("world2"): The package "maps" is required for `map_data()`.

plot_pacific() |> add_statistical_region("wcpfc_epo")
#> Error in ggplot2::map_data("world2"): The package "maps" is required for `map_data()`.

# Custom colours
plot_pacific() |>
  add_statistical_region("wcpfc_epo", colour1 = "darkorange", colour2 = "navy")
#> Error in ggplot2::map_data("world2"): The package "maps" is required for `map_data()`.

# With shading
plot_pacific() |> add_statistical_region("wcpfc", shading = TRUE)
#> Error in ggplot2::map_data("world2"): The package "maps" is required for `map_data()`.
plot_pacific() |>
  add_statistical_region("nx_sx", colour1 = "darkgreen", shading = TRUE)
#> Error in ggplot2::map_data("world2"): The package "maps" is required for `map_data()`.
```
