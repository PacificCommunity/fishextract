# fishextract - under active development - expect issues!

`fishextract` is an R package that aims to simplify, document, and
automate some of the most common functions used in the process of data
extraction and visualisation in OFP data.

## Installation

You can install the development version of `fishextract` like so:

``` r

# install.packages("pak")
pak::pak("PacificCommunity/fishextract")
library(fishextract)
```

## Main functions

| Command | Description |
|----|----|
| [`get_ace()`](https://pacificcommunity.github.io/fishextract/reference/get_ace.md) | extracts annual catch estimates data |
| [`get_logbook_catch()`](https://pacificcommunity.github.io/fishextract/reference/get_logbook_catch.md) | extracts operational **catch** data |
| [`get_logbook_effort()`](https://pacificcommunity.github.io/fishextract/reference/get_logbook_effort.md) | extracts operational **effort** data |
| [`get_n_vessels()`](https://pacificcommunity.github.io/fishextract/reference/get_n_vessels.md) | extracts number of vessels by flag and gear |
| [`get_aggregated_catch()`](https://pacificcommunity.github.io/fishextract/reference/get_aggregated_catch.md) | extracts aggregated **catch** data |
| [`get_aggregated_effort()`](https://pacificcommunity.github.io/fishextract/reference/get_aggregated_effort.md) | extracts aggregated **catch** data |
| [`get_aggregated_catcheffort()`](https://pacificcommunity.github.io/fishextract/reference/get_aggregated_catcheffort.md) | extracts aggregated **catch** and **effort** data |
| `catcheffort_by_region()` | extracts aggregated **catch** and **effort** data for a given bounding_box which could either be extracted from md2 using [`get_md2_shp()`](https://pacificcommunity.github.io/fishextract/reference/get_md2_shp.md) or custom defined regions using the [`as_region()`](https://pacificcommunity.github.io/fishextract/reference/as_region.md) function |
| [`plot_timeseries()`](https://pacificcommunity.github.io/fishextract/reference/plot_timeseries.md) | standardised plotting funciton to be used in conjunction with [`get_ace()`](https://pacificcommunity.github.io/fishextract/reference/get_ace.md), [`get_logbook_catch()`](https://pacificcommunity.github.io/fishextract/reference/get_logbook_catch.md) or [`get_n_vessels()`](https://pacificcommunity.github.io/fishextract/reference/get_n_vessels.md) |
| [`plot_pacific()`](https://pacificcommunity.github.io/fishextract/reference/plot_pacific.md) | plot plain pacific map as a ggplot layer |
| [`plot_statistical_region()`](https://pacificcommunity.github.io/fishextract/reference/plot_statistical_region.md) | graphic layer added to [`plot_pacific()`](https://pacificcommunity.github.io/fishextract/reference/plot_pacific.md) showing statisitical regions (e.g., WCPFC) |
| [`plot_assessment_region()`](https://pacificcommunity.github.io/fishextract/reference/plot_assessment_region.md) | graphic layer added to [`plot_pacific()`](https://pacificcommunity.github.io/fishextract/reference/plot_pacific.md) showing the stock assessment regions |

## Example usage

### Extracting Annual Catch Estimates (ACE)

``` r

get_ace() 
get_ace(species = c("YFT", "SKJ", "BET", "ALB"))
get_ace(species = list_species("tunas")) # same as above
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025)
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"))
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), flag = c("ID", "VN"))
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), flag = c("ID", "VN"), ocean = "NX")
```

### Plot ACE data (timeseries)

``` r

ace <- 
  get_ace(
    species = c("YFT", "SKJ", "BET", "ALB"), 
    year = 2004:2025, 
    gear = c("L", "S"), 
    flag = c("ID", "VN")
  )

ace |> plot_timeseries()
ace |> plot_timeseries(colour_by = SP_CODE)
ace |> plot_timeseries(colour_by = GEAR_CODE)
ace |> plot_timeseries(colour_by = SP_CODE, facet_by = GEAR_CODE, facet_scales = "free_y")
ace |> plot_timeseries(colour_by = GEAR_CODE, facet_by = FLAG_CODE)
```

### Get logbook data

Good to add filters here rather than running
[`get_logbook_catch()`](https://pacificcommunity.github.io/fishextract/reference/get_logbook_catch.md),
since the output could be quite large and take some time to run.

``` r

get_logbook_catch(flag = "KI") 
get_logbook_catch(flag = "FJ", species = c("YFT", "SKJ", "BET", "ALB"))
get_logbook_catch(flag = "FJ", species = list_species("tunas")) # same as above
get_logbook_catch(flag = "FJ", species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025)
get_logbook_catch(flag = "FJ", species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"))
get_logbook_catch(flag = c("ID", "VN"), species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"))
get_logbook_catch(flag = c("ID", "VN"),  species = c("YFT", "SKJ", "BET", "ALB"), year = 2004:2025, gear = c("L", "S"), in_wcpfc = FALSE)
```

### Plot logbook data (timeseries)

``` r

logbook <- 
  get_logbook_catch(
    species = c("YFT", "SKJ", "BET", "ALB"), 
    year = 2004:2025, 
    gear = c("L", "S"), 
    flag = c("ID", "VN")
    )

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
get_n_vessels(year = 2000:2025, flag = list_flags("WPEA")) |> plot_timeseries(colour_by = GEAR_CODE, facet_by = FLAG_CODE, facet_scales = "free_y")
```

### Plot aggregated data

``` r

get_aggregated_catch(in_wcpfc = TRUE, flag = "ID", year = 2020:2025, gear = "S") |>
  plot_aggregated_catch(
    pie_radius = 3,
    alpha = 0.7,
    colour_by = SP_CODE,
    facet_by = year,
    xlim = c(100, 160),
    ylim = c(-20, 25)
  )
```

``` r

get_aggregated_catch(
  year = 2025,
  flag = list_flags("WPEA"),
  gear = c("H", "K")
) |>
  plot_aggregated_catch(
    pie_radius = 2,
    alpha = 0.7,
    colour_by = SP_CODE,
    facet_by = GEAR_CODE,
    xlim = c(100, 160),
    ylim = c(-20, 25)
  )
```

### Useful maps

``` r

plot_pacific(show_eez = TRUE, xlim = c(95, 150), ylim = c(-15, 25), eez_flag = c("ID", "VN", "PH"))
```

``` r

plot_statistical_region("wcpfc_epo")
plot_statistical_region("wcpfc")
plot_statistical_region("npo_spo")
```

# Other functions

``` r

# list_species function to be finished***
list_species("tunas")
list_species("purse_seine")
list_species("scidata")

list_flags("WPEA")
```

### Comparing logbook data and ACE data

``` r


catch_data <- dplyr::bind_rows(
  get_ace(year = 2000:2025, gear = "S"),
  get_logbook_catch(year = 2000:2025, gear = "S")
) |>
dplyr::filter(!FLAG_CODE %in% c("FJ", "EP", "PA"))

catch_data |>
  plot_timeseries(colour_by = data_source, facet_by = FLAG_CODE, facet_scales = "free_y")
```
