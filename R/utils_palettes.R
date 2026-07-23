#' Species colour mapping
#'
#' Fixed colours for each species, keyed by name so mappings stay correct
#' even when only a subset of species appears in a plot. From: Okabe-Ito pallete.
#'
#' @keywords internal
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
#' @keywords internal
gear_colours <- function() {
  c(
    "S" = "#01BAEF",
    "L" = "#2A9D8F",
    "P" = "#E76F51",
    "T" = "#0B4F6C",
    "O" = "#9B5DE5"
  )
}

#' Ocean colour mapping
#'
#' Fixed colours for each ocean, keyed by name. Okabe-Ito pallete
#'
#' @importFrom RColorBrewer brewer.pal
#' @keywords internal
ocean_colours <- function() {
  set2_pallette <- RColorBrewer::brewer.pal(name = "Set2", n = 8)
  c(
    "AO" = set2_pallette[1],
    "IO" = set2_pallette[2],
    "SP" = set2_pallette[3],
    "EP" = set2_pallette[4],
    "WP" = set2_pallette[5],
    "NP" = set2_pallette[6],
    "WCPO" = set2_pallette[7]
  )
}

#' colours for geographical maps
#' @keywords internal
mapping_colours <- function(type) {
  switch(
    type,
    "land" = "#F5EFE0",
    "water" = "#DCEBF2",
    "land_outline" = "grey40",
  )
}
