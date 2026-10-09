# Get weight-frequency data

Get weight-frequency data

## Usage

``` r
get_weights(
  year = NULL,
  flag = NULL,
  gear = NULL,
  species = NULL,
  exclude_flag = NULL,
  exclude_gear = NULL,
  exclude_species = NULL
)
```

## Arguments

- year, flag, gear, species:

  filters to include (`NULL` = no filter).

- exclude_flag, exclude_gear, exclude_species:

  filters to exclude.

## Value

A tibble of weight-frequency records.
