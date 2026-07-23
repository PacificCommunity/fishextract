#' Pick the correct colour mapping for a grouping variable
#'
#' Internal helper used by plotting functions to select the right fixed
#' colour mapping (species, gear, etc.) based on the column being coloured.
#'
#' @param var_name Character string giving the name of the grouping column.
#'
#' @return A named character vector of colours, or \code{NULL} if no fixed
#'   mapping exists for \code{var_name} (falls back to ggplot's default).
#' @keywords internal
pkg_colour_lookup <- function(var_name) {
  switch(
    var_name,
    SP_CODE = species_colours(),
    GEAR_CODE = gear_colours(),
    OCEAN_CODE = ocean_colours(),
    NULL
  )
}

#' Look up display labels for known ACE grouping columns
#'
#' Internal helper returning a named lookup vector for columns with
#' package-defined display names, or `NULL` if `var_name` has no lookup
#' (in which case callers should fall back to default labelling).
#'
#' @param var_name String. Column name, e.g. `"GEAR_CODE"`.
#' @return A named character vector, or `NULL`.
#' @noRd
pkg_label_lookup <- function(var_name, abbreviate_flags = FALSE) {
  switch(
    var_name,
    GEAR_CODE = pkg_gear_lookup(),
    SP_CODE = pkg_species_lookup(),
    OCEAN_CODE = pkg_ocean_lookup(),
    FLAG_CODE = {
      flag_names <- get_flagname(simplify = TRUE)
      if (abbreviate_flags) abbreviate_flagname(flag_names) else flag_names
    },
    NULL
  )
}

pkg_gear_lookup <- function() {
  c(
    "S" = "Purse seine",
    "L" = "Longline",
    "G" = "Gillnet",
    "T" = "Troll",
    "P" = "Pole & Line",
    "G" = "Gillnet",
    "O" = "Other"
  )
}

pkg_species_lookup <- function() {
  c(
    "YFT" = "Yellowfin",
    "SKJ" = "Skipjack",
    "BET" = "Bigeye",
    "ALB" = "Albacore"
  )
}

pkg_ocean_lookup <- function() {
  c(
    "AO" = "Atlantic Ocean",
    "IO" = "Indian Ocean",
    "NP" = "North Pacific",
    "SP" = "South Pacific",
    "EP" = "East Pacific",
    "WP" = "West Pacific",
    "WX" = "WCPFC-CA"
  )
}
