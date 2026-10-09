catcheffort_byregion <- function(
  catcheffort,
  assessment_region,
  crs = 4326,
  show_plot = FALSE,
  ...
) {
  if (show_plot) {
    print(plot_assessment_region(
      assessment_region,
      plot = plot_aggregated_catch(catcheffort, ...)
    ))
  }

  catcheffort |>
    sf::st_as_sf(coords = c("lond", "latd"), crs = crs) |>
    sf::st_join(assessment_region, join = sf::st_within, left = FALSE) |>
    sf::st_drop_geometry() |>
    dplyr::summarise(
      sum_catch_mt = sum(.data$sum_catch_mt, na.rm = TRUE),
      hhooks = sum(.data$hhooks, na.rm = TRUE),
      VESS_N = sum(.data$VESS_N, na.rm = TRUE),
      days = sum(.data$days, na.rm = TRUE),
      sets = sum(.data$sets, na.rm = TRUE),
      .by = c(.data$region_id, .data$SP_CODE, .data$GEAR_CODE)
    ) |>
    tidyr::complete(
      region_id = assessment_region$region_id,
      .data$SP_CODE,
      .data$GEAR_CODE,
      fill = list(sum_catch_mt = 0, hhooks = 0, VESS_N = 0, days = 0, sets = 0)
    )
}

# x <- get_aggregated_catcheffort(
#   flag = "FJ",
#   year = 2020:2025,
#   species = "YFT",
#   gear = c("L", "H")
# )
# y <- get_md2_shp(species = "YFT")
# catcheffort_byregion(x, y)

# # x |> dplyr::filter(!is.na(sets))
