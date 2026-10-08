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
#' @noRd
species_colours <- function() {
  c(
    BET = "tomato1",
    YFT = "gold2",
    SKJ = "dodgerblue",
    ALB = "seagreen3",
    BILL = "gray60",
    OTH = "gray60",
    BLM = "black",
    BUM = "cyan1",
    MLS = "purple4",
    SWO = "#66CCFF"
    # "YFT" = "#F0E442",
    # "ALB" = "#009E73",
    # "BET" = "#D55E00",
    # "SKJ" = "#0072B2"
  )
}
#' Gear colour mapping
#'
#' Fixed colours for each gear type, keyed by name.
#'
#' @noRd
gear_colours <- function() {
  c(
    "G" = "#9d2a2a",
    "H" = "#F2C14E",
    "K" = "#CC79A7",
    "L" = "#2A9D8F",
    "N" = "#9da0a0",
    "O" = "#9B5DE5",
    "P" = "#E76F51",
    "R" = "#3e7d21",
    "S" = "#01BAEF",
    "T" = "#0B4F6C"
  )
}

#' Ocean colour mapping
#'
#' Fixed colours for each ocean, keyed by name. Okabe-Ito pallete
#'
#' @importFrom RColorBrewer brewer.pal
#' @noRd
ocean_colours <- function() {
  oceans <- c("AO", "IO", "SP", "EP", "WP", "NP", "WCPO")
  set2_pallette <- RColorBrewer::brewer.pal(name = "Set2", n = length(oceans))
  stats::setNames(set2_pallette, oceans)
}

#' Colours for geographical features
#'
#' @returns A named character vector of hex colours.
#' @noRd
mapping_colours <- function(type) {
  switch(
    type,
    "land" = "#F5EFE0",
    "water" = "#DCEBF2",
    "land_outline" = "grey40",
  )
}


#' Flag colours for plotting
#'
#' @returns A named character vector of hex colours.
#' @noRd
flag_colours <- function() {
  pal <- unname(grDevices::palette.colors(palette = "Polychrome 36"))
  stats::setNames(pal[c(1, 3, 6)], c("ID", "VN", "PH"))
}
