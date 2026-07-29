# TO DO
# this could just reference the table FISH_MASTER.ref.wcpfc_party
#' @export
get_flags <- function(
  group = c("WCPFC", "PNA", "FSMA", "WPEA")
  # year = NULL
) {
  flag_codes <-
    if (group == "WPEA") {
      c("ID", "VN", "PH")
    }
  return(flag_codes)
}
