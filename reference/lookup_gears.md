# Look up the gear description for a given gear code

Look up the gear description for a given gear code

## Usage

``` r
lookup_gears(gear = NULL, refresh = FALSE)
```

## Arguments

- gear:

  Optional character vector of gear codes to filter by. If `NULL`, all
  gears are returned.

- refresh:

  Logical. Force a re-query of the database and refresh the cache.
  Defaults to `FALSE`.
