# Create Pacific Ocean Region Maps

Generates a predefined Pacific Ocean map with region boundaries and
labels. The map type is specified by `type`, with each type
corresponding to a particular combination of lines and text annotations.

## Usage

``` r
plot_region_lines(
  type,
  colour1 = "red",
  colour2 = "blue",
  shading = FALSE,
  alpha = 0.2
)
```

## Arguments

- type:

  Character string indicating the map to produce. One of:

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

A ggplot object showing the requested Pacific Ocean region map.

## Examples

``` r
plot_region_lines("wcpfc")
#> Error in fun(colour1 = colour1, colour2 = colour2): argument "plot" is missing, with no default

plot_region_lines("wcpo_epo")
#> Error in fun(colour1 = colour1, colour2 = colour2): argument "plot" is missing, with no default

plot_region_lines("npo_spo")
#> Error in fun(colour1 = colour1, colour2 = colour2): argument "plot" is missing, with no default

plot_region_lines("nx_sx")
#> Error in fun(colour1 = colour1, colour2 = colour2): argument "plot" is missing, with no default

plot_region_lines("wcpfc_epo")
#> Error in fun(colour1 = colour1, colour2 = colour2): argument "plot" is missing, with no default

# Custom colours
plot_region_lines("wcpfc_epo",
         colour1 = "darkorange",
         colour2 = "navy")
#> Error in fun(colour1 = colour1, colour2 = colour2): argument "plot" is missing, with no default

# With shading
plot_region_lines("wcpfc", shading = TRUE)
#> Error in fun(colour1 = colour1, colour2 = colour2): argument "plot" is missing, with no default
plot_region_lines("nx_sx", colour1 = "darkgreen", shading = TRUE)
#> Error in fun(colour1 = colour1, colour2 = colour2): argument "plot" is missing, with no default
```
