# testing
func <- function() {
  last_update <-
    "
  SELECT max(entered_date) AS most_recent_date
  FROM log.sets_ll
  WHERE entered_date < getdate()" |>
    .db_query() |>
    dplyr::pull(most_recent_date)

  Sys.Date() - lubridate::as_date(last_update)
}
