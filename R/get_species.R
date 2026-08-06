#' @export
get_species <- function(
  group = c("tunas", "scidata", "purse_seine", "longline", "pole_line")
) {
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
      "MAK", # mako
      "SMA", # mako
      "LMA",
      "THR", # thresher
      "ALV", # thresher
      "PTH", # thresher
      "BTH", # thresher
      "POR",
      "SPN", # hammerhead
      "SPK", # hammerhead
      "SPL", # hammerhead
      "SPZ", # hammerhead
      "SPQ", # hammerhead
      "EUB", # hammerhead
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
      "THR", # thresher
      "ALV", # thresher
      "PTH", # thresher
      "BTH", # thresher
      "BSH",
      "MAK", # mako
      "SMA", # mako
    ),
    scidata_group3 = c(
      "BSH",
      "FAL",
      "OSC",
      "THR", # thresher
      "ALV", # thresher
      "PTH", # thresher
      "BTH", # thresher
      "MAK", # mako
      "SMA", # mako
      "POR",
      "SPN", # hammerhead
      "SPK", # hammerhead
      "SPL", # hammerhead
      "SPZ", # hammerhead
      "SPQ", # hammerhead
      "EUB", # hammerhead
      "RHN"
    )
  )
  species_groups[[group]]
}
