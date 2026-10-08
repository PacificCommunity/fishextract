.get_eez <- function(flag = NULL) {
  glue::glue(
    " 
SELECT 
  eez_filename, 
	ez_area.STAsText() AS area_polygon
FROM ref.eez_definitions d
INNER JOIN ref.eez_sources s ON s.eez_source_no = d.eez_source_no
WHERE d.eez_source_no = 1
  AND {.sql_filter('country_code', flag)}
"
  ) |>
    db_query(
      server = "NOUFAMESQL01",
      database = "tufman2"
    ) |>
    tidyr::drop_na() |>
    dplyr::mutate(geometry = sf::st_as_sfc(.data$area_polygon, crs = 4326)) |>
    sf::st_as_sf() |>
    sf::st_shift_longitude()
}
