# Add Stock assessment region boundaries to a Pacific map

Add Stock assessment region boundaries to a Pacific map

## Usage

``` r
plot_assessment_region(
  bounding_box,
  linewidth = 0.5,
  buffer = 0.05,
  plot = NULL,
  ...
)
```

## Arguments

- bounding_box:

  sf object either outputted from `get_md2_shp` or

- linewidth:

  Boundary line width. Defaults to `0.5`.

- buffer:

  Optional numeric. Buffer around outside of plotting area.

- plot:

  Optional ggplot object for the assessment regions to be plotted over

- ...:

  optional arguments to be passed to the `plot_pacific` function

## Value

A ggplot object with region boundary polygons added.

## Examples

``` r

plot_assessment_region(bounding_box = get_md2_shp(species ="YFT"))
#> Error in (function (cond) .Internal(C_tryCatchHelper(addr, 1L, cond)))(structure(list(message = c(`!` = "ODBC failed with error 00000 from \\\n             \033[32m[unixODBC][Driver Manager]\033[39m."),     trace = structure(list(call = list(pkgdown::build_site_github_pages(new_process = FALSE,         install = FALSE), build_site(pkg, preview = FALSE, install = install,         new_process = new_process, ...), build_site_local(pkg = pkg,         examples = examples, run_dont_run = run_dont_run, seed = seed,         lazy = lazy, override = override, preview = preview,         devel = devel, quiet = quiet), build_reference(pkg, lazy = lazy,         examples = examples, run_dont_run = run_dont_run, seed = seed,         override = override, preview = FALSE, devel = devel),         unwrap_purrr_error(purrr::map(topics, build_reference_topic,             pkg = pkg, lazy = lazy, examples_env = examples_env,             run_dont_run = run_dont_run)), withCallingHandlers(code,             purrr_error_indexed = function(err) {                cnd_signal(err$parent)            }), purrr::map(topics, build_reference_topic, pkg = pkg,             lazy = lazy, examples_env = examples_env, run_dont_run = run_dont_run),         map_("list", .x, .f, ..., .progress = .progress), with_indexed_errors(i = i,             names = names, error_call = .purrr_error_call, call_with_cleanup(map_impl,                 environment(), .type, .progress, n, names, i)),         withCallingHandlers(expr, error = function(cnd) {            if (i == 0L) {            }            else {                message <- c(i = "In index: {i}.")                if (!is.null(names) && !is.na(names[[i]]) &&                   names[[i]] != "") {                  name <- names[[i]]                  message <- c(message, i = "With name: {name}.")                }                else {                  name <- NULL                }                cli::cli_abort(message, location = i, name = name,                   parent = cnd, call = error_call, class = "purrr_error_indexed")            }        }), call_with_cleanup(map_impl, environment(), .type,             .progress, n, names, i), .f(.x[[i]], ...), withCallingHandlers(data_reference_topic(topic,             pkg, examples_env = examples_env, run_dont_run = run_dont_run),             error = function(err) {                cli::cli_abort("Failed to parse Rd in {.file {topic$file_in}}",                   parent = err, call = quote(build_reference()))            }), data_reference_topic(topic, pkg, examples_env = examples_env,             run_dont_run = run_dont_run), run_examples(tags$tag_examples[[1]],             env = if (is.null(examples_env)) NULL else new.env(parent = examples_env),             topic = tools::file_path_sans_ext(topic$file_in),             run_dont_run = run_dont_run), highlight_examples(code,             topic, env = env), downlit::evaluate_and_highlight(code,             fig_save = fig_save_topic, env = eval_env, output_handler = handler),         evaluate::evaluate(code, child_env(env), new_device = TRUE,             output_handler = output_handler), withRestarts(with_handlers({            for (expr in tle$exprs) {                ev <- withVisible(eval(expr, envir))                watcher$capture_plot_and_output()                watcher$print_value(ev$value, ev$visible, envir)            }            TRUE        }, handlers), eval_continue = function() TRUE, eval_stop = function() FALSE),         withRestartList(expr, restarts), withOneRestart(withRestartList(expr,             restarts[-nr]), restarts[[nr]]), doWithOneRestart(return(expr),             restart), withRestartList(expr, restarts[-nr]), withOneRestart(expr,             restarts[[1L]]), doWithOneRestart(return(expr), restart),         with_handlers({            for (expr in tle$exprs) {                ev <- withVisible(eval(expr, envir))                watcher$capture_plot_and_output()                watcher$print_value(ev$value, ev$visible, envir)            }            TRUE        }, handlers), eval(call), eval(call), withCallingHandlers(code,             message = `<fn>`, warning = `<fn>`, error = `<fn>`),         withVisible(eval(expr, envir)), eval(expr, envir), eval(expr,             envir), plot_assessment_region(bounding_box = get_md2_shp(species = "YFT")),         as_region(bounding_box), get_md2_shp(species = "YFT"),         sf::st_shift_longitude(sf::st_as_sf(db_query(server = "noufamesql01",             database = "md2", query = glue::glue("SELECT DiSTINCT\n          r.region_id,\n          --r.bounding_box_id,\n          CAST(b.geom.STAsText() AS VARCHAR(8000)) as geometry,\n          b.model_id\n        FROM md2.app.region_bounding_box r\n        JOIN md2.app.region b ON r.region_id = b.region_id\n        WHERE b.model_id = {model_id}")),             wkt = "geometry", crs = crs)), st_is_longlat(x),         st_crs(x), sf::st_as_sf(db_query(server = "noufamesql01",             database = "md2", query = glue::glue("SELECT DiSTINCT\n          r.region_id,\n          --r.bounding_box_id,\n          CAST(b.geom.STAsText() AS VARCHAR(8000)) as geometry,\n          b.model_id\n        FROM md2.app.region_bounding_box r\n        JOIN md2.app.region b ON r.region_id = b.region_id\n        WHERE b.model_id = {model_id}")),             wkt = "geometry", crs = crs), db_query(server = "noufamesql01",             database = "md2", query = glue::glue("SELECT DiSTINCT\n          r.region_id,\n          --r.bounding_box_id,\n          CAST(b.geom.STAsText() AS VARCHAR(8000)) as geometry,\n          b.model_id\n        FROM md2.app.region_bounding_box r\n        JOIN md2.app.region b ON r.region_id = b.region_id\n        WHERE b.model_id = {model_id}")),         tibble::as_tibble(DBI::dbGetQuery(conn = db_connection(...),             statement = query)), DBI::dbGetQuery(conn = db_connection(...),             statement = query), db_connection(...), DBI::dbConnect(drv = odbc::odbc(),             .connection_string = connection_string, ...), DBI::dbConnect(drv = odbc::odbc(),             .connection_string = connection_string, ...), .local(drv,             ...), OdbcConnection(dsn = dsn, ..., timezone = timezone,             timezone_out = timezone_out, encoding = encoding,             name_encoding = name_encoding, bigint = bigint, timeout = timeout,             driver = driver, server = server, database = database,             uid = uid, pwd = pwd, dbms.name = dbms.name, attributes = attributes,             interruptible = interruptible, .connection_string = .connection_string),         withCallingHandlers(ptr <- odbc_connect(connection_string,             timezone = timezone, timezone_out = timezone_out,             encoding = encoding, name_encoding = name_encoding,             bigint = bigint, timeout = timeout, r_attributes = attributes,             interruptible_execution = interruptible), error = function(cnd) {            check_quoting(args)        }), odbc_connect(connection_string, timezone = timezone,             timezone_out = timezone_out, encoding = encoding,             name_encoding = name_encoding, bigint = bigint, timeout = timeout,             r_attributes = attributes, interruptible_execution = interruptible),         `<fn>`("nanodbc/nanodbc.cpp:1187: 00000\n[unixODBC][Driver Manager]Can't open lib 'SQL Server' : file not found "),         cli::cli_abort(c(`!` = "ODBC failed with error {res$cnd_context_code} from \\\n             {.field {paste0(res$cnd_context_driver, collapse = '')}}.",             set_database_error_names(res$cnd_body), i = "From {.file {res$cnd_context_nanodbc}}."),             class = "odbc_database_error", call = call), rlang::abort(message,             ..., call = call, use_cli_format = TRUE, .frame = .frame)),         parent = c(0L, 1L, 2L, 3L, 4L, 5L, 4L, 7L, 8L, 9L, 8L,         8L, 12L, 12L, 14L, 15L, 16L, 17L, 18L, 19L, 20L, 21L,         20L, 23L, 24L, 18L, 26L, 27L, 26L, 18L, 18L, 31L, 32L,         33L, 32L, 35L, 36L, 37L, 35L, 35L, 40L, 40L, 40L, 43L,         43L, 45L, 46L, 47L, 47L, 0L, 50L, 51L), visible = c(TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,         TRUE, TRUE, TRUE, TRUE, FALSE, FALSE), namespace = c("pkgdown",         "pkgdown", "pkgdown", "pkgdown", "pkgdown", "base", "purrr",         "purrr", "purrr", "base", "purrr", "pkgdown", "base",         "pkgdown", "pkgdown", "pkgdown", "downlit", "evaluate",         "base", "base", "base", "base", "base", "base", "base",         "evaluate", "base", "base", "base", "base", "base", "base",         "fishextract", "fishextract", "fishextract", "sf", "sf",         "sf", "sf", "fishextract", "tibble", "DBI", "fishextract",         "DBI", "DBI", "odbc", "odbc", "base", "odbc", "odbc",         "cli", "rlang"), scope = c("::", "::", ":::", "::", ":::",         "::", "::", ":::", ":::", "::", ":::", "local", "::",         ":::", ":::", ":::", "::", "::", "::", "local", "local",         "local", "local", "local", "local", ":::", "::", "::",         "::", "::", "::", "::", "::", "::", "::", "::", "::",         "::", "::", "::", "::", "::", "::", "::", "::", "local",         ":::", "::", ":::", "local", "::", "::")), row.names = c(NA,     -52L), version = 2L, class = c("rlang_trace", "rlib_trace",     "tbl", "data.frame")), parent = NULL, body = c(x = "Can't open lib 'SQL Server' : file not found ",     i = "From \033[34mnanodbc/nanodbc.cpp:1187\033[39m."), rlang = list(        inherit = TRUE), call = pkgdown::build_site_github_pages(new_process = FALSE,         install = FALSE), use_cli_format = TRUE), class = c("odbc_database_error", "rlang_error", "error", "condition"))): error in evaluating the argument 'conn' in selecting a method for function 'dbGetQuery': ! ODBC failed with error 00000 from [unixODBC][Driver Manager].
#> ✖ Can't open lib 'SQL Server' : file not found
#> ℹ From nanodbc/nanodbc.cpp:1187.

# custom region
areas <- tibble::tribble(
  ~region_id, ~lon, ~lat,
  "1",         110,  0,
  "1",         145,  0,
  "1",         145,  20,
  "1",         110,  20,
  "2",         160,  0,
  "2",         165,  -20,
  "2",         190,  -15
)

plot_assessment_region(bounding_box = as_region(areas))

```
