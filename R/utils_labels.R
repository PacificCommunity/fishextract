#' Look up display labels for known ACE grouping columns
#'
#' Internal helper returning a named lookup vector for columns with
#' package-defined display names, or `NULL` if `var_name` has no lookup
#' (in which case callers should fall back to default labelling).
#'
#' @param var_name String. Column name, e.g. `"GEAR_CODE"`.
#' @param abbreviate_flags Logical. Abbreviates the flag names (useful for plotting purposes).
#' @return A named character vector, or `NULL`.
#' @export
label_lookup <- function(var_name, abbreviate_flags = FALSE) {
  switch(
    var_name,
    GEAR_CODE = pkg_gears_lookup(),
    SP_CODE = pkg_species_lookup(),
    OCEAN_CODE = pkg_ocean_lookup(),
    FLAG_CODE = {
      flag_names <- lookup_flagname()
      if (abbreviate_flags) abbreviate_flagname(flag_names) else flag_names
    },
    NULL
  )
}

pkg_gears_lookup <- function() {
  lookup_gears() |>
    tibble::deframe()
}

pkg_species_lookup <- function() {
  c(
    BET = "Bigeye",
    YFT = "Yellowfin",
    SKJ = 'Skipjack',
    ALB = "Albacore",
    BILL = 'Billfish',
    OTH = 'Other',
    BLM = 'Black Marlin',
    BUM = "Blue Marlin",
    MLS = "Striped Marlin",
    SWO = "Swordfish"
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
