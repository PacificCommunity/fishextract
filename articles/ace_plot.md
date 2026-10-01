# ace

``` r

library(fishextract)
```

``` r

ace <- 
get_ace(species = c("YFT", "SKJ", "BET", "ALB"), 
year = 2004:2025, 
gear = c("L", "S"), 
flag = c("ID", "VN"))

ace |> plot_timeseries()
ace |> plot_timeseries(colour_by = SP_CODE)
ace |> plot_timeseries(colour_by = GEAR_CODE)
ace |> plot_timeseries(colour_by = SP_CODE, facet_by = GEAR_CODE, facet_scales = "free_y")
ace |> plot_timeseries(colour_by = GEAR_CODE, facet_by = FLAG_CODE)
```
