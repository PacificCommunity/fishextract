run_catch <- function(
  ...,
  .result = tibble::tibble(FLAG_CODE = "FJ", YY = 2020L, sum_catch_mt = 1)
) {
  captured <- new.env()

  testthat::local_mocked_bindings(
    db_query = function(query, ...) {
      captured$sql <- query
      captured$dots <- list(...)
      .result
    }
  )

  captured$out <- get_logbook_catch(...)
  captured
}

gear_tables <- c(P = "pl", S = "ps", L = "ll", T = "tr", O = "ot")

# Output ---------------------------------------------------------------------

test_that("returns a tibble with renamed catch column and data_source", {
  out <- run_catch()$out

  expect_s3_class(out, "tbl_df")
  expect_named(out, c("FLAG_CODE", "YY", "sum_catch_mt", "data_source"))
  expect_equal(unique(out$data_source), "logbook_catch")
})

test_that("extra arguments are passed through to db_query()", {
  expect_equal(run_catch(server = "test_server")$dots$server, "test_server")
})

# Missing catch weights ------------------------------------------------------

test_that("rows with missing catch are dropped with a warning", {
  res <- tibble::tibble(
    FLAG_CODE = c("FJ", "FJ", "NZ"),
    sum_catch_mt = c(1, NA, NA)
  )

  expect_warning(
    out <- run_catch(.result = res)$out,
    "2 rows removed"
  )
  expect_equal(out$sum_catch_mt, 1)
})

test_that("no warning when all catch weights are present", {
  expect_no_warning(run_catch())
})

# Gear handling --------------------------------------------------------------

test_that("default queries all five gears joined by UNION ALL", {
  sql <- run_catch()$sql

  expect_equal(stringr::str_count(sql, "UNION ALL"), 4)
  purrr::walk(
    gear_tables,
    \(x) expect_match(sql, paste0("log.catch_", x), fixed = TRUE)
  )
})

test_that("each gear queries its own trips, sets and catch tables", {
  purrr::iwalk(gear_tables, \(suffix, g) {
    sql <- run_catch(gear = g)$sql

    expect_match(sql, paste0("log.trips_", suffix), fixed = TRUE)
    expect_match(sql, paste0("log.sets_", suffix), fixed = TRUE)
    expect_match(sql, paste0("log.catch_", suffix), fixed = TRUE)
    expect_false(grepl("UNION ALL", sql, fixed = TRUE))
  })
})

test_that("duplicate gears produce a single sub-query", {
  sql <- run_catch(gear = c("L", "L"))$sql

  expect_false(grepl("UNION ALL", sql, fixed = TRUE))
})

test_that("activity column and field ID follow the gear", {
  purrr::walk(c("P", "S", "L", "T"), \(g) {
    sql <- run_catch(gear = g)$sql

    expect_match(sql, paste0("s.", tolower(g), "_activity_id"), fixed = TRUE)
    expect_match(sql, paste0("'", g, "_ACT_ID'"), fixed = TRUE)
  })

  # "Other" gear borrows the longline activity lookup
  other <- run_catch(gear = "O")$sql
  expect_match(other, "s.l_activity_id", fixed = TRUE)
  expect_match(other, "'L_ACT_ID'", fixed = TRUE)
})

test_that("longline sums kg (incl. discards) to tonnes; others use sp_mt", {
  longline <- run_catch(gear = "L")$sql
  expect_match(longline, "c.sp_kg", fixed = TRUE)
  expect_match(longline, "c.spdiscard_kg", fixed = TRUE)
  expect_match(longline, "/ 1000", fixed = TRUE)

  purrr::walk(c("P", "S", "T", "O"), \(g) {
    sql <- run_catch(gear = g)$sql
    expect_match(sql, "SUM(c.sp_mt) AS sum_catch_mt", fixed = TRUE)
    expect_false(grepl("sp_kg", sql, fixed = TRUE))
  })
})

test_that("gear code and fleet columns are handled for 'other' gear", {
  standard <- run_catch(gear = "P")$sql
  expect_match(standard, "'P' AS GEAR_CODE", fixed = TRUE)
  expect_match(standard, "NULLIF(FLEET_CODE, '') AS FLEET_CODE", fixed = TRUE)

  other <- run_catch(gear = "O")$sql
  expect_match(other, "GEAR_CODE AS GEAR_CODE", fixed = TRUE)
  expect_match(other, "NULL AS FLEET_CODE", fixed = TRUE)
})

test_that("unrecognised gear codes fall back to the 'other' tables", {
  sql <- run_catch(gear = "X")$sql

  expect_match(sql, "log.trips_ot", fixed = TRUE)
  expect_false(grepl("UNION ALL", sql, fixed = TRUE))
})

# Filters --------------------------------------------------------------------

test_that("filter arguments are included in the SQL", {
  sql <- run_catch(
    flag = "FJ",
    fleet = "FLT1",
    species = "YFT",
    year = 2020:2021,
    exclude_flag = "XX",
    exclude_species = "SKJ"
  )$sql

  purrr::walk(
    c("FJ", "FLT1", "YFT", "2020", "XX", "SKJ"),
    \(x) expect_match(sql, x, fixed = TRUE)
  )
})

test_that("NULL filters do not inject values", {
  sql <- run_catch()$sql

  purrr::walk(
    c("FJ", "YFT", "SKJ"),
    \(x) expect_false(grepl(x, sql, fixed = TRUE))
  )
})

# show_sql -------------------------------------------------------------------

test_that("show_sql controls whether .clean_sql() is called", {
  called <- FALSE
  testthat::local_mocked_bindings(
    db_query = \(query, ...) tibble::tibble(sum_catch_mt = 1),
    .clean_sql = \(x) called <<- TRUE
  )

  get_logbook_catch(show_sql = FALSE)
  expect_false(called)

  get_logbook_catch(show_sql = TRUE)
  expect_true(called)
})
