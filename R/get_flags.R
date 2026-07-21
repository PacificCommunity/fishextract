# TO DO
# is year needed? does the nations within the agreements change each year?
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
