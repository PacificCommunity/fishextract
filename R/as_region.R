#' Create assessment regions from vertices or spatial objects
#'
#' Converts a table of vertices (or an existing spatial object) into an `sf`
#' object with one polygon per region. Rings are closed automatically and each
#' polygon is checked for self-intersections.
#'
#' @param points One of:
#'   * A data frame with `lon` and `lat` columns, with rows ordered around
#'     the perimeter of each region. Rows are split into separate polygons by
#'     the `group` column.
#'   * An `sf` object, returned unchanged.
#'   * An `sfc` or `bbox` object, returned as a single region called `"area"`.
#' @param group Character. Name of the column in `points` that identifies
#'   separate regions. If the column is not present, all rows are treated as
#'   one region called `"area"`. Defaults to `"region_id"`.
#' @param crs Coordinate reference system of the `lon`/`lat` values, passed to
#'   [sf::st_sfc()]. Defaults to `4326` (WGS84). Ignored when `points` is an
#'   `sf`, `sfc` or `bbox` object, which carry their own CRS.
#'
#' @return An `sf` object with one row per region, a `region_id` column and a
#'   polygon `geometry` column. Aborts if any polygon has fewer than three
#'   vertices or is self-intersecting.
#'
#' @examples
#' areas <- tibble::tribble(
#'   ~region_id, ~lon, ~lat,
#'   "1",         140,  -40,
#'   "1",         155,  -38,
#'   "1",         152,  -25,
#'   "1",         141,  -28,
#'   "2",         160,  -20,
#'   "2",         165,  -20,
#'   "2",         163,  -15
#' )
#'
#' # Two regions, split by region_id
#' as_region(areas)
#'
#' # From a bounding box
#' as_region(sf::st_bbox(c(xmin = 140, ymin = -40, xmax = 155, ymax = -25), crs = 4326))
#'
#' @export
as_region <- function(
  points,
  group = "region_id",
  crs = 4326
) {
  if (inherits(points, "sf")) {
    return(points)
  }
  if (inherits(points, c("sfc", "bbox"))) {
    return(sf::st_sf(region_id = "area", geometry = sf::st_as_sfc(points)))
  }

  if (!all(c("lon", "lat") %in% names(points))) {
    cli::cli_abort("{.arg points} needs {.val lon} and {.val lat} columns.")
  }

  # single shape if no grouping column is present
  ids <- if (group %in% names(points)) {
    points[[group]]
  } else {
    rep("area", nrow(points))
  }

  rings <- points[c("lon", "lat")] |>
    split(factor(ids, unique(ids))) |>
    lapply(\(x) {
      m <- as.matrix(x)
      if (nrow(m) < 3) {
        cli::cli_abort("Each group needs at least 3 points.")
      }
      if (!identical(m[1, ], m[nrow(m), ])) {
        m <- rbind(m, m[1, ])
      }
      list(m)
    })

  areas <- sf::st_sf(
    region_id = names(rings),
    geometry = sf::st_sfc(lapply(rings, sf::st_polygon), crs = crs)
  )

  bad <- !sf::st_is_valid(areas)
  if (any(bad)) {
    cli::cli_abort(
      "Self-intersecting shape in group{?s}: {.val {areas$group[bad]}}. Check point order."
    )
  }
  areas
}
