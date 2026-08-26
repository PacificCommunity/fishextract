#' @export
lookup_species <- function(
  group = c("tunas", "scidata", "purse_seine", "longline", "pole_line")
) {
  mako_sharks <- c("MAK", "SMA")
  thresher_sharks <- c("THR", "ALV", "PTH", "BTH")
  hammerheads <- c("SPN", "SPK", "SPL", "SPZ", "SPQ", "EUB")

  species_groups <- list(
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
    longline = c("YFT", "BET", "SKJ"),
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
    billfish = c("SWO", "MLS") # from claudio
  )
  species_groups[[group]]
}
