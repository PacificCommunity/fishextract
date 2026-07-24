
# fishextract

<!-- badges: start -->
<!-- badges: end -->

`fishextract` aims to simplify, document, and automate some of the most common functions used in the process of data extraction and visualisation in OFP data. 

## Installation

You can install the development version of fishextract like so:

``` r
# install.packages("remotes")
remotes::install.packages("FreddieJH/fishextract")
library(fishextract)
```

## Example

### Extract ACE data

``` r
get_ace() 
get_ace(species = c("YFT", "SKJ", "BET", "ALB"))
get_ace(species = get_species("tunas")) # same as above
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025)
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"))
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), flag = c("ID", "VN"))
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), flag = c("ID", "VN"), ocean = "NX")
```

### Plot ACE data (timeseries)

``` r
ace <- get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), flag = c("ID", "VN"))

ace |> plot_timeseries()
ace |> plot_timeseries(colour_by = SP_CODE)
ace |> plot_timeseries(colour_by = GEAR_CODE)
ace |> plot_timeseries(colour_by = SP_CODE, facet_by = GEAR_CODE, facet_scales = "free_y")
ace |> plot_timeseries(colour_by = GEAR_CODE, facet_by = FLAG_CODE)
```

### Get logbook data

``` r
get_logbook_catch() 
get_logbook_catch(species = c("YFT", "SKJ", "BET", "ALB"))
get_logbook_catch(species = get_species("tunas")) # same as above
get_logbook_catch(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025)
get_logbook_catch(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"))
get_logbook_catch(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), flag = c("ID", "VN"))
get_logbook_catch(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), flag = c("ID", "VN"), in_wcpfc = FALSE)
```

### Plot logbook data (timeseries)

``` r
logbook <- get_logbook_catch(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), flag = c("ID", "VN"))

logbook |> plot_timeseries()
logbook |> plot_timeseries(colour_by = SP_CODE)
logbook |> plot_timeseries(colour_by = GEAR_CODE)
logbook |> plot_timeseries(colour_by = SP_CODE, facet_by = GEAR_CODE, facet_scales = "free_y")
logbook |> plot_timeseries(colour_by = GEAR_CODE, facet_by = FLAG_CODE)
```

### Get number of vessels

``` r
nvessels <- get_n_vessels(year = 2000:2025)
nvessels |> plot_timeseries()
nvessels |> plot_timeseries(colour_by = GEAR_CODE)
nvessels |> plot_timeseries(colour_by = GEAR_CODE, facet_by = FLAG_CODE)
get_n_vessels(year = 2000:2025, flags = get_flags("WPEA")) |> plot_timeseries(colour_by = GEAR_CODE, facet_by = FLAG_CODE, facet_scales = "free_y")
```

### Useful maps


``` r
plot_map("wcpfc_epo")
plot_map("wcpfc")
plot_map("npo_spo")
```

# Other functions



``` r
# GET_SPECIES function to be finished***
get_species("tunas")
get_species("purse_seine")
get_species("scidata")

get_flags("WPEA")
```

