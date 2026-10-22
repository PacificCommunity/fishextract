#' List the FLAG_CODE values for a given group
#'
#' @param group (e.g. `WPEA`)
#'
#' @return A character vector of FLAG_CODEs
#' @export
list_flags <- function(
  group = c("WCPFC", "PNA", "WPEA", "DWFN")
) {
  # note we could just use FISH_MASTER.ref.entities

  # pna_flags <-
  #   glue::glue(
  #     "
  # SELECT *
  #   FROM ref.entities
  # WHERE 1 = 1
  #   AND pna_member = 1
  #   AND entity_type = 'C'
  # "
  #   ) |>
  #   db_query()

  switch(
    group,
    # WCPFC = c("ID", "VN", "PH"),
    WPEA = c("ID", "VN", "PH"),
    PNA = c("FM", "KI", "MH", "NR", "PG", "PW", "SB", "TV"),
    DWFN = c("JP", "US", "CA", "KR", "TW"),
    FFA = c(
      "AU",
      "CK",
      "FM",
      "FJ",
      "KI",
      "GL",
      "LN",
      "PX",
      "MH",
      "NR",
      "NZ",
      "NU",
      "PW",
      "PG",
      "WS",
      "SB",
      "TK",
      "TO",
      "TV",
      "VU"
    )
  )
}
