# TO DO
# this could just reference the table FISH_MASTER.ref.entities
#' @export
list_flags <- function(
  group = c("WCPFC", "PNA", "WPEA", "DWFN")
  # year = NULL
) {
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
    DWFN = c("JP", "US", "CA", "KR", "TW")
  )
}
