# Look up flag (country) names by code

Returns the full and abbreviated name(s) corresponding to one or more
flag codes. Results are sourced from `ref.countries` on first call and
cached for the rest of the session — subsequent calls (including
single-code lookups like `lookup_flagname("VN")`) filter the cached
table locally rather than re-querying the database.

## Usage

``` r
lookup_flagname(flag = NULL, simplify = FALSE, refresh = FALSE)
```

## Arguments

- flag:

  Optional character vector of flag codes to filter by. If `NULL`, all
  flags are returned.

- simplify:

  Logical. If `TRUE`, return a named character vector of `flag_name`,
  named by `flag_code`, rather than the full tibble. Defaults to
  `FALSE`.

- refresh:

  Logical. Force a re-query of the database and refresh the cache.
  Defaults to `FALSE`.

## Details

`flag_name` and `flag_name_abbr` are sentence-cased and trimmed via
[`stringr::str_to_sentence()`](https://stringr.tidyverse.org/reference/case.html)/[`stringr::str_trim()`](https://stringr.tidyverse.org/reference/str_trim.html).
Where `flag_name_abbr` is missing, it is filled with `flag_name`.

## Examples

``` r
if (FALSE) { # \dontrun{
lookup_flagname()
lookup_flagname(flag = c("JP", "KR"))
lookup_flagname("VN")
#>       VN
#> "Vietnam"
lookup_flagname(refresh = TRUE) # force a fresh pull from the database
} # }
```
