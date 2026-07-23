.pkg_cache <- NULL

.onLoad <- function(libname, pkgname) {
  .pkg_cache <<- new.env(parent = emptyenv())
}

#' Get or compute a cached value
#'
#' Internal helper implementing a simple memoise-on-first-call pattern
#' backed by `.pkg_cache`. If `key` is already cached (and `refresh` is
#' `FALSE`), the cached value is returned; otherwise `compute` is
#' evaluated, stored under `key`, and returned.
#'
#' @param key String. Cache key, e.g. `"flagnames"`.
#' @param compute A zero-argument function/expression producing the
#'   value to cache if not already present.
#' @param refresh Logical. Force recomputation and overwrite the cache.
#' @return The cached (or freshly computed) value.
#' @noRd
pkg_cached <- function(key, compute, refresh = FALSE) {
  if (refresh || is.null(.pkg_cache[[key]])) {
    .pkg_cache[[key]] <- compute()
  }
  .pkg_cache[[key]]
}
