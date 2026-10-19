# Look up all the fleets for a given country or gear

Look up all the fleets for a given country or gear

## Usage

``` r
lookup_fleets(gear = NULL, flag = NULL, fleet = NULL, refresh = FALSE)
```

## Arguments

- gear:

  Optional character vector of gear codes to filter by. If `NULL`, all
  gears are returned.

- flag:

  Optional character vector of flag codes to filter by. If `NULL`, all
  flags are returned.

- fleet:

  Optional character vector of fleet codes to filter by. If `NULL`, all
  fleets are returned.

- refresh:

  Logical. Force a re-query of the database and refresh the cache.
  Defaults to `FALSE`.
