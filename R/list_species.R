#' List the SP_CODE values for a given group of species
#'
#' @param group (otpions include `scidata`, `tunas`, `purse_seine`, `longline`, `pole_line`)
#'
#' @return A character vector of FLAG_CODEs
#' @export
list_species <- function(group) {
  allowed_groups <- c(
    "tunas",
    "scidata",
    "purse_seine",
    "longline",
    "billfish",
    "ssi",
    "pole_line",
    "scidata_group1",
    "scidata_group2",
    "scidata_group3"
  )
  verified_group <- match.arg(group, choices = allowed_groups)
  mako_sharks <- c("MAK", "SMA")
  thresher_sharks <- c("THR", "ALV", "PTH", "BTH")
  hammerheads <- c("SPN", "SPK", "SPL", "SPZ", "SPQ", "EUB")
  billfish <- c("SWO", "MLS") # from claudio
  ssi <- c("RHN", "OCS", "FAL", "RMB", "SHK", "RMV") # see https://meetings.wcpfc.int/file/5594/download

  species_list <- list(
    scidata = c(
      "ALB",
      "BET",
      "SKJ",
      "YFT",
      "MLS",
      "BUM",
      "BLM",
      "SWO",
      "SSP",
      "SFA",
      "BSH",
      "FAL",
      "OCS",
      mako_sharks,
      "LMA",
      thresher_sharks,
      "POR",
      hammerheads,
      "RHN"
    ),
    tunas = c("YFT", "ALB", "BET", "SKJ"),
    purse_seine = c("YFT", "BET", "SKJ"),
    longline = c("YFT", "BET", "ALB"),
    pole_line = c("YFT", "BET", "SKJ"),
    scidata_group1 = c(
      "BET",
      "SKJ",
      "YFT",
      "BUM",
      "SSP",
      "SFA"
    ),
    scidata_group2 = c(
      "ALB",
      "MLS",
      "SWO",
      "PBF",
      thresher_sharks,
      "BSH",
      mako_sharks
    ),
    scidata_group3 = c(
      "BSH",
      "FAL",
      "OSC",
      thresher_sharks,
      mako_sharks,
      "POR",
      hammerheads,
      "RHN"
    ),
    billfish = billfish
  )
  species_list[[verified_group]]
}
