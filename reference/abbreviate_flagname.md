# Abbreviate country/flag names for compact display

Converts full country names into short, conventional forms suitable for
tight spaces (facet strips, table columns, legends). Known acronym-style
exceptions (e.g. "Federated states of micronesia" to "FSM") are handled
via a manual lookup, checked first. Names not in the lookup fall back to
general rules: trailing "..., Kingdom of" / "..., Republic of" style
suffixes are dropped, and "Islands" is abbreviated to "Is.". Anything
matching neither is returned trimmed but otherwise unchanged.

## Usage

``` r
abbreviate_flagname(country_name)
```

## Arguments

- country_name:

  Character vector of country names, as returned by
  [`lookup_flagname()`](https://pacificcommunity.github.io/fishextract/reference/lookup_flagname.md).

## Value

Character vector of shortened names, same length as input.

## Examples

``` r
abbreviate_flagname(c(
  "Federated states of micronesia",
  "Tonga, kingdom of",
  "Marshall islands"
))
#> [1] "FSM"          "Tonga"        "Marshall Is."
#> [1] "FSM"          "Tonga"        "Marshall Is."
```
