#' Plot logbook reporting catch trends by year
#'
#' Takes the output of [logbook_coverage()] and plots `coverage` as a
#' line against year, optionally coloured and/or faceted by another
#' grouping column still present in the data (e.g. `FLAG_CODE`,
#' `GEAR_CODE`, `SP_CODE`). `ace_catch` and `logbook_catch` are
#' re-summed internally over `YY`, `colour_by` and `facet_by`, and
#' `coverage` is recalculated from these totals (rather than averaged),
#' so lines are always correct regardless of which other grouping
#' columns remain in `data`.
#'
#' @param data A tibble as returned by [logbook_coverage()], containing
#'   at least `YY`, `ace_catch` and `logbook_catch`.
#' @param colour_by Optional. Bare column name to colour lines by (e.g.
#'   `FLAG_CODE`). Defaults to `NULL` (single line, no colour grouping).
#' @param facet_by Optional. Bare column name to facet by (e.g.
#'   `GEAR_CODE`). Defaults to `NULL` (no facetting).
#' @param facet_scales Passed to [ggplot2::facet_wrap()]'s `scales`
#'   argument when `facet_by` is supplied. Defaults to `"fixed"`.
#' @param hline Logical. If `TRUE` (default), adds a dashed reference
#'   line at `coverage = 1` (full reporting).
#'
#' @return A [ggplot2::ggplot()] object.
#'
#' @examples
#' \dontrun{
#' coverage_output <- logbook_coverage(in_wcpfc = TRUE, group_species = TRUE)
#'
#' # Single line, overall coverage by year
#' plot_logbook_catch(coverage_output)
#'
#' # Coloured by flag
#' plot_logbook_catch(coverage_output, colour_by = FLAG_CODE)
#'
#' # Coloured by flag, faceted by gear, free y-scales per panel
#' plot_logbook_catch(coverage_output, colour_by = FLAG_CODE, facet_by = GEAR_CODE, facet_scales = "free_y")
#' }
#'
#' @importFrom rlang enquo quo_is_null as_name
#'
#' @export
plot_logbook_catch <- function(
  data,
  colour_by = NULL,
  facet_by = NULL,
  facet_scales = "fixed",
  hline = TRUE
) {
  colour_by <- rlang::enquo(colour_by)
  facet_by <- rlang::enquo(facet_by)

  group_vars <- c(
    "YY",
    if (!rlang::quo_is_null(colour_by)) rlang::as_name(colour_by),
    if (!rlang::quo_is_null(facet_by)) rlang::as_name(facet_by)
  )

  plot_data <-
    data |>
    dplyr::summarise(
      ace_catch = sum(ace_catch),
      logbook_catch = sum(logbook_catch),
      .by = dplyr::all_of(group_vars)
    ) |>
    dplyr::mutate(
      coverage = dplyr::case_when(
        ace_catch > 0 & logbook_catch > 0 ~ (logbook_catch / ace_catch),
        ace_catch == 0 & logbook_catch > 0 ~ NA,
        ace_catch > 0 & logbook_catch == 0 ~ 0,
        .default = NA
      ),
      coverage = dplyr::if_else(coverage > 1, 1, coverage)
    )

  p <-
    ggplot2::ggplot(
      plot_data,
      ggplot2::aes(
        x = YY,
        y = coverage,
        colour = !!colour_by,
        group = !!colour_by
      )
    ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::labs(x = NULL, y = "Logbook coverage", colour = NULL) +
    ggplot2::theme_minimal()

  if (hline) {
    p <- p +
      ggplot2::geom_hline(
        yintercept = 1,
        linetype = "dashed",
        colour = "grey50"
      )
  }

  if (!rlang::quo_is_null(facet_by)) {
    p <- p +
      ggplot2::facet_wrap(ggplot2::vars(!!facet_by), scales = facet_scales)
  }

  p
}
