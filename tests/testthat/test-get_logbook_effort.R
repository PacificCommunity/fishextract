run_effort <- function(...) {
  captured <- new.env()

  testthat::local_mocked_bindings(
    db_query = function(query, ...) {
      captured$sql <- query
      captured$dots <- list(...)
      tibble::tibble(FLAG_CODE = "FJ", YY = 2020L)
    }
  )

  captured$out <- get_logbook_effort(...)
  captured
}

gear_tables <- c(P = "pl", S = "ps", L = "ll", T = "tr")

# Output ---------------------------------------------------------------------

test_that("returns a tibble tagged with data_source", {
  res <- run_effort()

  expect_s3_class(res$out, "tbl_df")
  expect_equal(unique(res$out$data_source), "logbook_effort")
})

test_that("extra arguments are passed through to db_query()", {
  res <- run_effort(server = "test_server")

  expect_equal(res$dots$server, "test_server")
})

# Gear handling --------------------------------------------------------------

test_that("default queries all four gears joined by UNION ALL", {
  sql <- run_effort()$sql

  expect_equal(stringr::str_count(sql, "UNION ALL"), 3)
  purrr::walk(
    gear_tables,
    \(x) expect_match(sql, paste0("log.trips_", x), fixed = TRUE)
  )
})

test_that("each gear queries its own tables and activity column", {
  purrr::iwalk(gear_tables, \(suffix, g) {
    sql <- run_effort(gear = g)$sql

    expect_match(sql, paste0("log.trips_", suffix), fixed = TRUE)
    expect_match(sql, paste0("log.sets_", suffix), fixed = TRUE)
    expect_match(sql, paste0("'", g, "' AS GEAR_CODE"), fixed = TRUE)
    expect_match(sql, paste0("s.", tolower(g), "_activity_id"), fixed = TRUE)
    expect_false(grepl("UNION ALL", sql, fixed = TRUE))
  })
})

test_that("duplicate gears produce a single sub-query", {
  sql <- run_effort(gear = c("L", "L"))$sql

  expect_false(grepl("UNION ALL", sql, fixed = TRUE))
})

test_that("effort columns are selected for own gear and NULL-padded otherwise", {
  longline <- run_effort(gear = "L")$sql
  expect_false(grepl("NULL AS hooks_n", longline, fixed = TRUE))
  expect_match(longline, "NULL AS bait", fixed = TRUE)
  expect_match(longline, "NULL AS school_id", fixed = TRUE)

  # The same effort columns appear in every branch so UNION ALL lines up
  troll <- run_effort(gear = "T")$sql
  expect_match(troll, "NULL AS hooks_n", fixed = TRUE)
  expect_match(troll, "NULL AS effort_factor", fixed = TRUE)
})

test_that("unsupported gear codes error", {
  expect_error(run_effort(gear = "X"))
})

# Filters --------------------------------------------------------------------

test_that("filter arguments are included in the SQL", {
  sql <- run_effort(
    flag = "FJ",
    fleet = "FLT1",
    year = 2020:2021,
    exclude_flag = "XX"
  )$sql

  expect_match(sql, "FJ", fixed = TRUE)
  expect_match(sql, "FLT1", fixed = TRUE)
  expect_match(sql, "2020", fixed = TRUE)
  expect_match(sql, "XX", fixed = TRUE)
})

test_that("NULL filters do not inject values", {
  sql <- run_effort()$sql

  expect_false(grepl("FJ", sql, fixed = TRUE))
})

# show_sql -------------------------------------------------------------------

test_that("show_sql controls whether .clean_sql() is called", {
  called <- FALSE
  testthat::local_mocked_bindings(
    db_query = \(query, ...) tibble::tibble(),
    .clean_sql = \(x) called <<- TRUE
  )

  get_logbook_effort(show_sql = FALSE)
  expect_false(called)

  get_logbook_effort(show_sql = TRUE)
  expect_true(called)
})
