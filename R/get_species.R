#' @export
get_species <- function(
  group = c("tunas", "scidata", "purse_seine", "longline", "pole_line")
) {
  species_codes <-
    if (group == "tunas") {
      c("YFT", "ALB", "BET", "SKJ")
    } else if (group == "purse_seine") {
      c("YFT", "BET", "SKJ")
    } else if (group == "longline") {
      c("YFT", "BET", "SKJ")
    } else if (group == "pole_line") {
      c("YFT", "BET", "SKJ")
    }
  return(species_codes)
}
