# TO DO
get_species <- function(
  group = c("tunas", "scidata", "purse_seine")
) {
  species_codes <-
    if (group == "tunas") {
      c("YFT", "ALB", "BET", "SKJ")
    } else if (group == "purse_seine") {
      c("YFT", "BET", "SKJ")
    }
  return(species_codes)
}
