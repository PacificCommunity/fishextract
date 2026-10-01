# Package plotting theme

A consistent ggplot2 theme used across all plotting functions in this
package. Built on
[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
with minor gridlines removed, shaded facet strips, and the legend placed
below the plot.

## Usage

``` r
theme_fishextract(base_size = 16)
```

## Arguments

- base_size:

  Base font size, in points. Defaults to 11.

## Value

A `ggplot2` theme object that can be added to a `ggplot` using `+`.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_fishextract()

```
