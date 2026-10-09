# logbook_catch

``` r

library(fishextract)
```

## Set-level information

By default, the
[`get_logbook_catch()`](https://pacificcommunity.github.io/fishextract/reference/get_logbook_catch.md)
function returns the catch at the fishing set-level.

``` r

get_logbook_catch(flag = "PG", year = 2020:2021, species = list_species("tunas")) 
```
