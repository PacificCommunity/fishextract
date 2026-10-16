
# fishextract <img src="man/figures/fishextract-logo.png" align="right" height="150" />
<!-- badges: start -->
<!-- badges: end -->

`fishextract` is an R package that aims to simplify, document, and automate some of the most common functions used in the process of data extraction and visualisation in OFP data. 

## Installation

You can install the development version of `fishextract` like so:

``` r
# install.packages("pak")
pak::pak("PacificCommunity/fishextract")
library(fishextract)
```

## Main functions

| Command | Description |
| --- | --- |
| `get_ace()` | extracts annual catch estimates data |
| `get_logbook_catch()` | extracts operational **catch** data |
| `get_logbook_effort()` | extracts operational **effort** data |
| `get_n_vessels()` | extracts number of vessels by flag and gear |
| `get_aggregated_catch()` | extracts aggregated **catch** data |
| `get_aggregated_effort()` | extracts aggregated **catch** data |
| `get_aggregated_catcheffort()` | extracts aggregated **catch** and **effort** data |
| `catcheffort_by_region()` | extracts aggregated **catch** and **effort** data for a given bounding_box which could either be extracted from md2 using `get_md2_shp()` or custom defined regions using the `as_region()` function|
| `plot_timeseries()` | standardised plotting funciton to be used in conjunction with `get_ace()`,  `get_logbook_catch()` or `get_n_vessels()` |
| `plot_pacific()` | plot plain pacific map as a ggplot layer |
| `plot_statistical_region()` | graphic layer added to `plot_pacific()` showing statisitical regions (e.g., WCPFC) |
| `plot_assessment_region()` | graphic layer added to `plot_pacific()` showing the stock assessment regions |

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

Good to add filters here rather than running `get_logbook_catch()`, since the output could be quite large and take some time to run. 

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



### Extracting CPUE by region

You can extract an existing assessment region from MD2, and get the CPUE metrics for a each of the regions. Note that model 130 is the YFT. 

``` r
agg_cpue <- get_aggregated_catcheffort(
   flag = "KI",
   year = 2020:2025,
   species = "YFT",
   gear = c("L", "S")
 )
md2_region <- get_md2_shp(model_id = 130)
catcheffort_byregion(agg_cpue, md2_region, show_plot = TRUE, facet_by = GEAR_CODE)
```
... or you can define your own cusom regions. 

``` r
custom_latlons <- 
  tibble::tribble(
   ~region_id , ~lon , ~lat ,
   "1"        ,  110 ,   -0 ,
   "1"        ,  110 ,   20 ,
   "1"        ,  150 ,   20 ,
   "1"        ,  150 ,    0 ,
   "2"        ,  160 ,   -0 ,
   "2"        ,  160 ,   -5 ,
   "2"        ,  190 ,   -5 ,
   "2"        ,  190 ,  -10 ,
   "2"        ,  200 ,  -10 ,
   "2"        ,  200 ,    0
 )

custom_regions <- as_region(custom_latlons)
catcheffort_byregion(agg_cpue, custom_regions, show_plot = TRUE, facet_by = GEAR_CODE)
```


## Get length and weight frequencies

``` r
get_lengths(year = 2025, flag = "KI")
get_weights(year = 2020:2025, flag = "AU")
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

The `list_*` functions can be useful in automated processes. 

``` r
list_species("tunas")
list_species("purse_seine")
list_species("scidata")
list_species("scidata_group1") # scidata standard section 1 bullet point 1
list_species("scidata_group2")

list_flags("WPEA")
list_flags("PNA")
```


The `lookup_*` functions can be useful to automate the processes of labelling. Note these functions are automatically applied in the `fishextract::plot_*` functions in the legends and facet labels. 

``` r

lookup_flagname(c("ID", "VN", "PH"))
lookup_species(c("YFT", "BET"))
lookup_gears(c("L", "S", "P"))
lookup_fleets(flag = "AU")
lookup_fleets(gear = "P")
lookup_fleets(gear = "P", flag = "ID")
lookup_length_codes()
lookup_weight_codes()
```


### Comparing logbook data and ACE data

```r

catch_data <- dplyr::bind_rows(
  get_ace(year = 2000:2025, gear = "S"),
  get_logbook_catch(year = 2000:2025, gear = "S")
) |>
dplyr::filter(!FLAG_CODE %in% c("FJ", "EP", "PA"))

catch_data |>
  plot_timeseries(colour_by = data_source, facet_by = FLAG_CODE, facet_scales = "free_y")

```

