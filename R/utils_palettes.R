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
lookup_colour <- function(var_name) {
  switch(
    var_name,
    SP_CODE = species_colours(),
    GEAR_CODE = gear_colours(),
    OCEAN_CODE = ocean_colours(),
    FLAG_CODE = flag_colours(),
    NULL
  )
}


#' Species colour mapping
#'
#' Fixed colours for each species, keyed by name so mappings stay correct
#' even when only a subset of species appears in a plot. From: Okabe-Ito pallete.
#'
#' @export
species_colours <- function() {
  c(
    "YFT" = "#F0E442",
    "ALB" = "#009E73",
    "BET" = "#D55E00",
    "SKJ" = "#0072B2"
  )
}
#' Gear colour mapping
#'
#' Fixed colours for each gear type, keyed by name.
#'
#' @export
gear_colours <- function() {
  c(
    "S" = "#01BAEF",
    "L" = "#2A9D8F",
    "P" = "#E76F51",
    "T" = "#0B4F6C",
    "O" = "#9B5DE5",
    "H" = "#F2C14E",
    "K" = "#CC79A7"
  )
}

#' Ocean colour mapping
#'
#' Fixed colours for each ocean, keyed by name. Okabe-Ito pallete
#'
#' @importFrom RColorBrewer brewer.pal
#' @export
ocean_colours <- function() {
  oceans <- c("AO", "IO", "SP", "EP", "WP", "NP", "WCPO")
  set2_pallette <- RColorBrewer::brewer.pal(name = "Set2", n = length(oceans))
  setNames(set2_pallette, oceans)
}

#' colours for geographical maps
#' @export
mapping_colours <- function(type) {
  switch(
    type,
    "land" = "#F5EFE0",
    "water" = "#DCEBF2",
    "land_outline" = "grey40",
  )
}
#' @export
flag_colours <- function() {
  flag_pal <- palette.colors(palette = "Polychrome 36")
  c(
    "ID" = flag_pal[1],
    "VN" = flag_pal[3],
    "PH" = flag_pal[6]
  )
}
