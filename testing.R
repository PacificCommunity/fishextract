library(ggplot2)
sum_ace(
  ocean = "WX",
  # flag = c("ID", "VN"),
  # gear = c("P", "S", "L", "H"),
  species = c("SKJ"),
  year = 1970:2025
) |>
  dplyr::summarise(
    sum = sum(sum_catch_mt),
    .by = -c(FLAG_CODE, sum_catch_mt)
  ) |>
  ggplot() +
  aes(YY, sum, col = GEAR_CODE) +
  geom_line() +
  geom_point() +
  scale_y_log10()

logbook_catch(
  in_wcpfc = 1,
  flag = "ID",
  year = 2000:2025,
  species = c("YFT", "BET", "ALB", "SKJ")
) |>
  ggplot() +
  aes(YY, sp_kg, col = SP_CODE) +
  geom_line() +
  geom_point() +
  scale_y_log10()


logbook_catch(
  in_wcpfc = 1,
  flag = "VN",
  gear = "L",
  year = 2000:2025,
  species = c("YFT", "BET", "ALB", "SKJ")
) |>
  ggplot() +
  aes(YY, sp_kg, col = SP_CODE) +
  geom_line() +
  geom_point() +
  scale_y_log10()

logbook_catch(
  in_wcpfc = 1,
  flag = "EC",
  gear = c("P"),
  year = 2025,
  species = c("YFT", "BET", "ALB", "SKJ")
)

logbook_catch(
  in_wcpfc = 1,
  gear = c("S"),
  year = 2010:2025,
  species = c("YFT", "BET", "ALB", "SKJ")
)

plot_ace_timeseries()
plot_ace_timeseries(combined_plot = TRUE)

sum_ace(
  "WX",
  species = c("ALB", "BET", "YFT", "SKJ"),
  group_species = TRUE,
  group_flags = TRUE,
  group_gears = FALSE
) |>
  dplyr::mutate(
    GEAR_CODE = dplyr::case_when(
      GEAR_CODE == "L" ~ "L",
      GEAR_CODE == "P" ~ "P",
      GEAR_CODE == "S" ~ "S",
      GEAR_CODE == "T" ~ "T",
      .default = "O"
    )
  ) |>
  dplyr::arrange(desc(YY)) |>
  ggplot2::ggplot(ggplot2::aes(YY, sum_catch_mt, fill = GEAR_CODE)) +
  ggplot2::geom_col()

sum_ace(
  "WX",
  species = c("ALB", "BET", "YFT", "SKJ"),
  group_species = FALSE,
  group_flags = TRUE,
  group_gears = TRUE
) |>
  dplyr::arrange(desc(YY)) |>
  dplyr::summarise(new = sum(sum_catch_mt), .by = c(YY, SP_CODE)) |>
  ggplot2::ggplot(ggplot2::aes(YY, new, col = SP_CODE, fill = SP_CODE)) +
  ggplot2::geom_line() +
  ggplot2::geom_point()


sum_ace(
  "WX",
  species = species,
  year = 2024:2025,
  group_flags = TRUE,
  group_gears = TRUE
)


sum_ace(
  "WX",
  species = c("ALB", "BET", "YFT", "SKJ"),
  gear = "S",
  year = 2025,
  group_species = FALSE,
  group_flags = TRUE,
  group_gears = TRUE
) |>
  dplyr::mutate(prop = sum_catch_mt / 1787386)
sum_ace(
  "WX",
  species = c("ALB", "BET", "YFT", "SKJ"),
  gear = "S",
  year = 2025,
  group_species = TRUE,
  group_flags = TRUE,
  group_gears = TRUE
)

sum_ace(
  "WX",
  # species = NULL,
  gear = "S",
  year = 2012:2025,
  flag = "ID",
  group_species = TRUE,
  group_flags = TRUE,
  group_gears = TRUE
)


library(tidyverse)
devtools::load_all()
xx <-
  expand_grid(
    ocean = "WX",
    species = c("BET", "YFT", "SKJ", "ALB"),
    gear = c("S", "L", "T", "P"),
    year = 2024:2025
  ) |>
  mutate(
    ace_catch = pmap_dbl(
      .l = list(ocean = ocean, species = species, gear = gear, year = year),
      .f = \(ocean, species, gear, year) {
        sum_ace(
          ocean = ocean,
          species = species,
          gear = gear,
          year = year,
          group_flags = TRUE
        )$sum_catch_mt
      }
    )
  ) |>
  add_count(gear, year, wt = ace_catch, name = "gear_catch") |>
  add_count(year, wt = ace_catch, name = "total_catch") |>
  add_count(species, year, wt = ace_catch, name = "species_catch") |>
  # add_count(gear, species, year, wt = ace_catch, name = "species_gear_catch") |>
  pivot_wider(
    values_from = c(ace_catch, species_catch, gear_catch, total_catch),
    names_from = year
  )


xx |>
  filter(species == "YFT") |>
  filter(gear == "S") |>
  mutate(test = ace_catch_2025 / gear_catch_2025) |>
  pull(test) |>
  unique()


sum_ace(
  ocean = "WX",
  species = c("YFT", "BET", "ALB", "SKJ"),
  gear = c("S", "P")
) |>
  plot_ace(colour_by = SP_CODE, facet_by = GEAR_CODE, facet_scales = "free_y")


library(DBI)
library(tidyverse)
library(odbc)
channel <- dbConnect(
  odbc::odbc(),
  .connection_string = "driver=SQL Server;server=OFP_DBS;database=fish_master"
)
countries.query <- "SELECT country_code, country_name FROM Ref.countries"
countries <- dbGetQuery(channel, countries.query, as.is = TRUE)
countries <-
  countries |>
  mutate(
    CC = substr(country_name, 1, 3),
    CC = ifelse(country_code == 'TW', 'TAI', CC)
  )
countries <- rbind(
  countries,
  data.frame(
    country_code = 'EP',
    country_name = 'EASTERN PACIFIC NEI',
    CC = 'ZEP'
  )
)
countries <-
  countries |>
  mutate(
    country_name = ifelse(
      country_code == 'KR',
      'REPUBLIC OF KOREA',
      ifelse(
        country_code == 'HN',
        'REPUBLIC OF HONDURAS',
        ifelse(
          country_code == 'PT',
          'EU-PORTUGAL',
          ifelse(
            country_code == 'ES',
            'EU-SPAIN',
            ifelse(country_code == 'TO', 'KINGDOM OF TONGA', country_name)
          )
        )
      )
    )
  )
