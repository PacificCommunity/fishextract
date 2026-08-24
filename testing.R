library(tidyverse)
devtools::load_all()

glue::glue(
  "
  SELECT TOP 10 *
  FROM tufman2.unload2.unloadings
  "
) |>
  db_query()


ace_cn <- get_ace(flag = "CN")

library(tidyverse)
get_ace(flag = "CN", ungroup_eez = TRUE) |>
  dplyr::summarise(
    eez_sum_catch = sum(sum_catch_mt),
    .by = c(FLAG_CODE, GEAR_CODE, SP_CODE, YY)
  ) |>
  dplyr::full_join(get_ace(flag = "CN")) |>
  ggplot(aes(eez_sum_catch, sum_catch_mt)) +
  geom_point()


get_ace(
  # flag = c("TW"),
  eez = "I5",
  year = 2000:2025,
  ungroup_eez = TRUE,
  species = "ALB"
) |>
  ggplot(aes(YY, sum_catch_mt, col = FLAG_CODE)) +
  geom_line() +
  geom_point()


flag_list <- c("NZ", "PF", "US", "AU", "CA")
params <- list(
  flag = c("NZ", "PF", "US", "AU", "CA"),
  species = "ALB",
  gear = "T",
  year = 2000:2025
)

do.call(get_ace, c(params, list(ocean = "SX"))) |>
  pivot_wider(names_from = FLAG_CODE, values_from = sum_catch_mt)

do.call(get_ace, c(params, list(ungroup_eez = TRUE))) |>
  mutate(flag_eez = paste(FLAG_CODE, EEZ_CODE)) |>
  pivot_wider(names_from = flag_eez, values_from = sum_catch_mt)


get_aggregated_catch(species = lookup_species("tunas")) |>
  plot_aggregated_catch(facet_by = SP_CODE, pie_radius = 0.3) |>
  add_line("wcpfc")
