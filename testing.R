library(tidyverse)

glue::glue(
  "
  SELECT TOP 10 *
  FROM tufman2.unload2.unloadings
  "
) |>
  db_query()


ace_byEEZ_cn <- get_ace_byEEZ(flag = "CN")
ace_cn <- get_ace(flag = "CN")

library(tidyverse)
ace_byEEZ_cn |>
  dplyr::summarise(
    catch = sum(sum_catch_mt),
    .by = c(FLAG_CODE, GEAR_CODE, SP_CODE, YY)
  ) |>
  dplyr::full_join(ace_cn) |>
  ggplot(aes(catch, sum_catch_mt)) +
  geom_point()
