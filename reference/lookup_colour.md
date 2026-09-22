# Pick the correct colour mapping for a grouping variable

Internal helper used by plotting functions to select the right fixed
colour mapping (species, gear, etc.) based on the column being coloured.

## Usage

``` r
lookup_colour(var_name)
```

## Arguments

- var_name:

  Character string giving the name of the grouping column.

## Value

A named character vector of colours, or `NULL` if no fixed mapping
exists for `var_name` (falls back to ggplot's default).
