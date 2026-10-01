test_ocean <- "WX"
test_year <- 2000:2024
test_df <- get_ace(ocean = test_ocean, year = test_year)

test_that("plot_timeseries() returns a ggplot object", {
  # Default value column (sum_catch_mt)
  expect_s3_class(plot_timeseries(test_df), "ggplot")

  # Explicit value column
  expect_s3_class(plot_timeseries(test_df, colour_by = SP_CODE), "ggplot")

  # With faceting
  expect_s3_class(plot_timeseries(test_df, facet_by = GEAR_CODE), "ggplot")
})
