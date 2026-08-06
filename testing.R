library(tidyverse)

glue::glue(
  "
  SELECT TOP 10 *
  FROM tufman2.unload2.unloadings
  "
) |>
  db_query()
