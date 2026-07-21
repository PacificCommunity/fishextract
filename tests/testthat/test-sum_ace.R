test_ocean <- "WX"
test_year <- 2024

test_that("sum_ace hits the real database and returns a well-formed tibble", {
  out <- sum_ace(ocean = test_ocean, year = test_year)

  expect_s3_class(out, "tbl_df")
  expect_setequal(
    names(out),
    c("OCEAN_CODE", "FLAG_CODE", "GEAR_CODE", "SP_CODE", "YY", "sum_catch_mt")
  )
  expect_true(nrow(out) > 0)
  expect_true(all(!is.na(out$sum_catch_mt)))
  expect_true(all(out$sum_catch_mt >= 0))
})

test_that("year filter is actually enforced by the DB query", {
  out <- sum_ace(ocean = test_ocean, year = test_year)
  expect_true(all(out$YY == test_year))

  out_multi <- sum_ace(ocean = test_ocean, year = c(test_year, test_year + 1))
  expect_true(all(out_multi$YY %in% c(test_year, test_year + 1)))
})


test_that("ocean filter is actually enforced by the DB query", {
  out <- sum_ace(ocean = test_ocean, year = test_year)
  expect_true(all(out$OCEAN_CODE == test_ocean))
})

test_that("group_species = TRUE matches manual aggregation of the ungrouped extract", {
  ungrouped <- sum_ace(ocean = test_ocean, year = test_year)
  grouped <- sum_ace(ocean = test_ocean, year = test_year, group_species = TRUE)

  expect_false("SP_CODE" %in% names(grouped))

  manual <- ungrouped |>
    dplyr::summarise(
      sum_catch_mt = sum(sum_catch_mt),
      .by = -c(SP_CODE, sum_catch_mt)
    ) |>
    dplyr::arrange(OCEAN_CODE, FLAG_CODE, GEAR_CODE, YY)

  expect_equal(
    grouped |> dplyr::arrange(OCEAN_CODE, FLAG_CODE, GEAR_CODE, YY),
    manual
  )
})

test_that("group_flags = TRUE matches manual aggregation of the ungrouped extract", {
  ungrouped <- sum_ace(ocean = test_ocean, year = test_year)
  grouped <- sum_ace(ocean = test_ocean, year = test_year, group_flags = TRUE)

  expect_false("FLAG_CODE" %in% names(grouped))

  manual <- ungrouped |>
    dplyr::summarise(
      sum_catch_mt = sum(sum_catch_mt),
      .by = -c(FLAG_CODE, sum_catch_mt)
    ) |>
    dplyr::arrange(OCEAN_CODE, GEAR_CODE, SP_CODE, YY)

  expect_equal(
    grouped |> dplyr::arrange(OCEAN_CODE, GEAR_CODE, SP_CODE, YY),
    manual
  )
})

test_that("total catch is conserved when grouping (no rows silently dropped)", {
  ungrouped <- sum_ace(ocean = test_ocean, year = test_year)
  grouped_sp <- sum_ace(
    ocean = test_ocean,
    year = test_year,
    group_species = TRUE
  )
  grouped_both <- sum_ace(
    ocean = test_ocean,
    year = test_year,
    group_species = TRUE,
    group_flags = TRUE
  )

  expect_equal(sum(ungrouped$sum_catch_mt), sum(grouped_sp$sum_catch_mt))
  expect_equal(sum(ungrouped$sum_catch_mt), sum(grouped_both$sum_catch_mt))
})

test_that("a narrower filter never returns more rows than a wider one", {
  wide <- sum_ace(ocean = test_ocean, year = test_year)
  narrow <- sum_ace(
    ocean = test_ocean,
    year = test_year,
    gear = wide$GEAR_CODE[1]
  )

  expect_true(nrow(narrow) <= nrow(wide))
  expect_true(all(narrow$GEAR_CODE == wide$GEAR_CODE[1]))
})
