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
    dplyr::mutate(sp_name = stringr::str_to_title(sp_name))

  out <- if (is.null(species)) {
    species_tbl
  } else {
    species_tbl |> dplyr::filter(SP_CODE %in% species)
  }

  return(out)
}
