#' Plot logbook coverage by flag and year
#'
#' Visualises logbook reporting coverage (as calculated by
#' `get_logbook_coverage()`) as a flag x year heatmap, with each tile shaded by
#' coverage and labelled with the coverage percentage. Facets by gear
#' automatically if more than one gear is present in the data.
#'
#' @param coverage_data A tibble as returned by `get_logbook_coverage()`,
#'   containing at least `FLAG_CODE`, `YY`, and `coverage` columns (and
#'   optionally `GEAR_CODE`). If `NULL` (the default), `get_logbook_coverage()`
#'   is called using `...`.
#' @param flag_order Optional character vector giving the order flags
#'   should appear on the y-axis, top to bottom (as per
#'   `ggplot2::scale_y_discrete(limits = ...)`). Defaults to descending
#'   mean coverage across the data.
#' @param ... Additional arguments passed to `get_logbook_coverage()` when
#'   `coverage_data` is `NULL` (e.g. `in_wcpfc`, `flag`, `gear`,
#'   `species`, `year`, `group_species`).
#'
#' @return A `ggplot` object: a tile plot of year (x) by flag (y),
#'   filled by coverage (0-1, `RdYlBu` palette), with each tile labelled
#'   with its coverage as a percentage (or `"X"` where coverage is
#'   missing).
#'
#' @details
#' Coverage is expected on a 0-1 scale, where 1 indicates full logbook
#' coverage relative to ACE catch. Missing coverage (e.g. no ACE catch
#' to compare against) is plotted as `"X"` rather than a percentage.
#' Label colour switches between black and white depending on how far a
#' tile's coverage sits from the midpoint of the colour scale, to keep
#' text legible against both light and dark fills.
#'
#' @examples
#' \dontrun{
#' get_logbook_coverage(in_wcpfc = TRUE, group_species = TRUE, gear = "L", year = 2004:2025) |>
#'   plot_logbook_coverage()
#'
#' # or call get_logbook_coverage() implicitly
#' plot_logbook_coverage(in_wcpfc = TRUE, group_species = TRUE, gear = "S", year = 2004:2025)
#' }
#'
#' @export
plot_logbook_coverage <- function(
  coverage_data = NULL,
  ...
) {
  if (is.null(coverage_data)) {
    coverage_data <- calc_coverage(...)
  }

  p <-
    coverage_data |>
    dplyr::summarise(
      coverage = mean(coverage),
      .by = c(YY, FLAG_CODE, GEAR_CODE)
    ) |>
    dplyr::mutate(coverage = tidyr::replace_na(coverage, -1)) |>
    dplyr::arrange(desc(FLAG_CODE)) |>
    dplyr::mutate(FLAG_CODE = forcats::fct_inorder(FLAG_CODE)) |>
    ggplot2::ggplot(ggplot2::aes(x = YY, y = FLAG_CODE, fill = coverage)) +
    ggplot2::geom_tile(color = "black") +
    ggplot2::scale_fill_gradientn(
      colors = grDevices::hcl.colors(20, "RdYlBu"),
      limits = c(0, 1)
    ) +
    ggnewscale::new_scale_fill() +
    ggplot2::geom_text(
      ggplot2::aes(
        label = dplyr::if_else(
          coverage == -1,
          "X",
          paste0(as.character(round(coverage * 100)), "%")
        ),
        color = dplyr::if_else(abs(coverage - 0.50) < 0.36, FALSE, TRUE)
      ),
      size = 3
    ) +
    ggplot2::scale_color_manual(
      values = c("TRUE" = "white", "FALSE" = "black"),
      guide = "none"
    ) +
    ggplot2::scale_x_continuous(
      position = "top",
      breaks = seq(min(coverage_data$YY), max(coverage_data$YY), 1),
      expand = c(0, 0)
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      axis.title.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(size = 10),
      legend.position = "none"
    )

  p
}
