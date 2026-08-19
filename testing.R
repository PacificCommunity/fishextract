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
  flag = "CN",
  eez = "I5",
  year = 2000:2024,
  ungroup_eez = TRUE,
  species = "ALB"
)
