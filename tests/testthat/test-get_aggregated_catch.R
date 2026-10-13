capture_sql <- function(...) {
  sql <- NULL
  with_mocked_bindings(
    get_aggregated_catch(...),
    db_query = function(sql_query, ...) {
      sql <<- sql_query
      tibble::tibble()
    },
    # simple stand-in so filters are easy to spot in the SQL
    .sql_filter = function(col, value, exclude = FALSE) {
      if (is.null(value)) {
        "TRUE"
      } else {
        paste0(
          col,
          if (exclude) " NOT IN " else " IN ",
          "[",
          paste(value, collapse = "|"),
          "]"
        )
      }
    },
    lookup_gears = function() tibble::tibble(GEAR_CODE = c("L", "S", "P"))
  )
  stringr::str_squish(sql)
}

select_clause <- function(sql) sub("^SELECT (.*) FROM best\\..*$", "\\1", sql)
group_clause <- function(sql) sub("^.*GROUP BY ", "", sql)

# grouping ----------------------------------------------------------------

test_that("SELECT and GROUP BY are correct for every grouping combination", {
  tidyr::expand_grid(
    group_species = c(TRUE, FALSE),
    group_fleets = c(TRUE, FALSE)
  ) |>
    purrr::pwalk(\(group_species, group_fleets) {
      sql <- capture_sql(
        group_species = group_species,
        group_fleets = group_fleets
      )

      expected_select <- c(
        "FLAG_CODE",
        if (!group_fleets) "NULLIF(FLEET_CODE, '') AS FLEET_CODE",
        "GEAR_CODE",
        if (!group_species) "SP_CODE",
        "YY AS year",
        "MM AS month",
        "SUM(SP_MT) AS sum_catch_mt",
        "CAST(latd AS DECIMAL) AS latd",
        "CAST(lond AS DECIMAL) AS lond"
      )
      expected_group <- c(
        "FLAG_CODE",
        if (!group_fleets) "NULLIF(FLEET_CODE, '')",
        "GEAR_CODE",
        if (!group_species) "SP_CODE",
        "YY",
        "MM",
        "CAST(latd AS DECIMAL)",
        "CAST(lond AS DECIMAL)"
      )

      label <- glue::glue(
        "group_species = {group_species}, group_fleets = {group_fleets}"
      )
      expect_identical(
        select_clause(sql),
        paste(expected_select, collapse = ", "),
        label = label
      )
      expect_identical(
        group_clause(sql),
        paste(expected_group, collapse = ", "),
        label = label
      )
    })
})

test_that("generated SQL has no stray or doubled commas", {
  tidyr::expand_grid(
    group_species = c(TRUE, FALSE),
    group_fleets = c(TRUE, FALSE)
  ) |>
    purrr::pwalk(\(group_species, group_fleets) {
      sql <- capture_sql(
        group_species = group_species,
        group_fleets = group_fleets
      )
      expect_no_match(sql, ",\\s*,")
      expect_no_match(sql, ",\\s*(FROM|GROUP BY|WHERE)\\b")
    })
})

test_that("defaults group by species and collapse fleets", {
  sql <- capture_sql()
  expect_match(select_clause(sql), "\\bSP_CODE\\b")
  expect_no_match(sql, "FLEET_CODE")
})

test_that("group_species = TRUE drops SP_CODE from SELECT and GROUP BY", {
  sql <- capture_sql(group_species = TRUE)
  expect_no_match(select_clause(sql), "SP_CODE")
  expect_no_match(group_clause(sql), "SP_CODE")
})

test_that("group_species = TRUE still applies species filters", {
  sql <- capture_sql(group_species = TRUE, species = c("SKJ", "YFT"))
  expect_match(sql, "SP_CODE IN [SKJ|YFT]", fixed = TRUE)
})

test_that("group_fleets = FALSE blanks empty FLEET_CODE strings in SELECT and GROUP BY", {
  sql <- capture_sql(group_fleets = FALSE)
  expect_match(
    select_clause(sql),
    "NULLIF(FLEET_CODE, '') AS FLEET_CODE",
    fixed = TRUE
  )
  expect_match(group_clause(sql), "NULLIF(FLEET_CODE, '')", fixed = TRUE)
})

# filters -----------------------------------------------------------------

test_that("include filters are passed to the correct columns", {
  sql <- capture_sql(
    year = 2020:2022,
    flag = c("JP", "KR"),
    gear = "L",
    species = "SKJ"
  )
  expect_match(sql, "YY IN [2020|2021|2022]", fixed = TRUE)
  expect_match(sql, "FLAG_CODE IN [JP|KR]", fixed = TRUE)
  expect_match(sql, "GEAR_CODE IN [L]", fixed = TRUE)
  expect_match(sql, "SP_CODE IN [SKJ]", fixed = TRUE)
})

test_that("exclude filters are passed to the correct columns", {
  sql <- capture_sql(
    exclude_flag = "US",
    exclude_gear = "S",
    exclude_species = "BET"
  )
  expect_match(sql, "FLAG_CODE NOT IN [US]", fixed = TRUE)
  expect_match(sql, "GEAR_CODE NOT IN [S]", fixed = TRUE)
  expect_match(sql, "SP_CODE NOT IN [BET]", fixed = TRUE)
})

test_that("NULL filters leave the WHERE clause unrestricted", {
  sql <- capture_sql(in_wcpfc = NULL)
  expect_no_match(sql, "\\[")
})

test_that("in_wcpfc is coerced to numeric", {
  expect_match(
    capture_sql(in_wcpfc = TRUE),
    "in_wcpfc_area IN [1]",
    fixed = TRUE
  )
  expect_match(
    capture_sql(in_wcpfc = FALSE),
    "in_wcpfc_area IN [0]",
    fixed = TRUE
  )
})

test_that("the A_BEST aggregated tables are used", {
  sql <- capture_sql()
  expect_match(sql, "FROM best.A_BEST_AGG_CATCH c", fixed = TRUE)
  expect_match(
    sql,
    "JOIN best.A_BEST_AGG a ON a.A_BEST_ID = c.A_BEST_ID",
    fixed = TRUE
  )
})

# validation --------------------------------------------------------------

test_that("invalid gear codes are rejected", {
  expect_error(capture_sql(gear = "XX"))
})

test_that("multiple valid gear codes are accepted", {
  expect_match(
    capture_sql(gear = c("L", "S")),
    "GEAR_CODE IN [L|S]",
    fixed = TRUE
  )
})

# side effects and return value -------------------------------------------

test_that("show_sql calls .clean_sql() and still queries the database", {
  cleaned <- FALSE
  queried <- FALSE
  with_mocked_bindings(
    get_aggregated_catch(show_sql = TRUE),
    db_query = function(...) {
      queried <<- TRUE
      tibble::tibble()
    },
    .sql_filter = function(...) "TRUE",
    .clean_sql = function(x) {
      cleaned <<- TRUE
      invisible(x)
    }
  )
  expect_true(cleaned)
  expect_true(queried)
})

test_that("show_sql = FALSE does not call .clean_sql()", {
  with_mocked_bindings(
    get_aggregated_catch(show_sql = FALSE),
    db_query = function(...) tibble::tibble(),
    .sql_filter = function(...) "TRUE",
    .clean_sql = function(x) stop(".clean_sql() should not be called")
  )
  succeed()
})

test_that("... is forwarded to db_query() and its result is returned unchanged", {
  expected <- tibble::tibble(FLAG_CODE = "JP", sum_catch_mt = 10)
  received <- NULL
  out <- with_mocked_bindings(
    get_aggregated_catch(server = "test_server"),
    db_query = function(sql_query, ...) {
      received <<- list(...)
      expected
    },
    .sql_filter = function(...) "TRUE"
  )
  expect_identical(received$server, "test_server")
  expect_identical(out, expected)
})
