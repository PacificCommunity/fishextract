library(testthat)
library(stringr)

# Run the function with the database layer mocked out.
# `db_query()` returns what it received, so we can inspect the SQL and any `...` args.
run_mocked <- function(...) {
  local_mocked_bindings(
    lookup_gears = function() tibble::tibble(GEAR_CODE = c("L", "S", "P")),
    .clean_sql = function(x) message("sql_cleaned"),
    db_query = function(sql, ...) {
      list(sql = as.character(sql), dots = list(...))
    }
  )
  get_aggregated_catch(...)
}

sql_for <- function(...) run_mocked(...)$sql
has <- function(sql, pattern) str_detect(sql, fixed(pattern))

test_that("default query targets the A_BEST tables and key output columns", {
  sql <- sql_for()

  expect_true(has(sql, "best.A_BEST_AGG_CATCH"))
  expect_true(has(sql, "best.A_BEST_AGG"))
  expect_true(has(sql, "SUM(SP_MT) AS sum_catch_mt"))
  expect_true(has(sql, "NULLIF(FLEET_CODE, '') AS FLEET_CODE"))
  expect_true(has(sql, "in_wcpfc_area"))
})

test_that("group_species controls whether SP_CODE is selected and grouped", {
  by_species <- sql_for(group_species = FALSE)
  pooled <- sql_for(group_species = TRUE)

  # SP_CODE appears in both SELECT and GROUP BY when not grouping species
  expect_equal(str_count(by_species, fixed("SP_CODE,")), 2)
  expect_false(has(pooled, "SP_CODE"))
})

test_that("filters are passed through to the query", {
  sql <- sql_for(year = 2020, flag = "AU", gear = "L", species = "YFT")

  expect_true(has(sql, "2020"))
  expect_true(has(sql, "AU"))
  expect_true(has(sql, "YFT"))
  expect_true(has(sql, "'L'"))
})

test_that("exclusion filters are applied", {
  sql <- sql_for(
    exclude_flag = "CN",
    exclude_gear = "S",
    exclude_species = "SKJ"
  )

  expect_true(has(sql, "CN"))
  expect_true(has(sql, "SKJ"))
  expect_true(has(sql, "NOT") || has(sql, "<>") || has(sql, "!="))
})

test_that("in_wcpfc is coerced to numeric (or dropped when NULL)", {
  expect_true(has(sql_for(in_wcpfc = TRUE), "in_wcpfc_area"))
  expect_true(has(sql_for(in_wcpfc = FALSE), "in_wcpfc_area"))
  expect_false(has(sql_for(in_wcpfc = NULL), "in_wcpfc_area ="))
})

test_that("invalid gear codes are rejected", {
  expect_error(run_mocked(gear = "XX"), "should be one of")
})

test_that("multiple valid gear codes are accepted", {
  expect_no_error(run_mocked(gear = c("L", "S")))
})

test_that("show_sql triggers .clean_sql() only when requested", {
  expect_message(run_mocked(show_sql = TRUE), "sql_cleaned")
  expect_no_message(run_mocked(show_sql = FALSE))
})

test_that("extra arguments are forwarded to db_query()", {
  out <- run_mocked(con = "my_connection")

  expect_equal(out$dots$con, "my_connection")
})

test_that("db_query() result is returned unchanged", {
  expected <- tibble::tibble(FLAG_CODE = "AU", year = 2020L, sum_catch_mt = 1.5)

  local_mocked_bindings(
    lookup_gears = function() tibble::tibble(GEAR_CODE = "L"),
    db_query = function(sql, ...) expected
  )

  expect_identical(get_aggregated_catch(), expected)
})
