# Get length-frequency data

Get length-frequency data

## Usage

``` r
get_lengths(
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

A tibble of length-frequency records.
