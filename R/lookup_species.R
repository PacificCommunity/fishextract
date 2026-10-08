#' Look up the species names given the species codes
#'
#' @param species Optional character vector of species codes to filter by.
#'   If `NULL`, all species are returned.
#' @param refresh Logical. Force a re-query of the database and refresh
#'   the cache. Defaults to `FALSE`.
#'
#' @export
lookup_species <- function(species = NULL, refresh = FALSE) {
  species_tbl <- pkg_cached(
    "species_tbl",
    compute = function() {
      query <-
        "
      SELECT
        sp_code AS SP_CODE, 
        sp_name, 
        sp_sci_name
      FROM ref.species
      "
      db_query(query)
    },
    refresh = refresh
  ) |>
    dplyr::mutate(sp_name = stringr::str_to_title(.data$sp_name)) |>
    dplyr::filter(.data$SP_CODE != "   ")

  out <- if (is.null(species)) {
    species_tbl
  } else {
    species_tbl |> dplyr::filter(.data$SP_CODE %in% species)
  }

  return(out)
}
