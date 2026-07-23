#' Plot ACE catch trends by year
#'
#' Takes the output of [get_ace()] and plots total catch (t) as a line
#' against year, optionally coloured and/or faceted by another grouping
#' column still present in the data (e.g. `OCEAN_CODE`, `FLAG_CODE`,
#' `GEAR_CODE`, `SP_CODE`). Data are re-aggregated internally over `YY`,
#' `colour_by` and `facet_by` so lines are always clean, regardless of
#' which other grouping columns remain in `data`. Where `colour_by` or
#' `facet_by` is `GEAR_CODE` or `SP_CODE`, full names are shown in place
#' of raw codes.
#'
#' @param data A tibble as returned by [get_ace()], containing at least
#'   `YY` and `sum_catch_mt`.
#' @param colour_by Optional. Bare column name to colour lines by (e.g.
#'   `SP_CODE`). Defaults to `NULL` (single line, no colour grouping).
#' @param facet_by Optional. Bare column name to facet by (e.g.
#'   `OCEAN_CODE`). Defaults to `NULL` (no facetting).
#' @param facet_scales Passed to [ggplot2::facet_wrap()]'s `scales`
#'   argument when `facet_by` is supplied. Defaults to `"fixed"`.
#'
#' @return A [ggplot2::ggplot()] object.
#'
#' @examples
#' \dontrun{
#' ace_output <- get_ace(ocean = "WX", species = c("YFT", "SKJ"))
#'
#' # Single line, total catch by year
#' plot_ace(ace_output)
#'
#' # Coloured by species (full names shown in legend)
#' plot_ace(ace_output, colour_by = SP_CODE)
#'
#' # Coloured by species, faceted by gear (full names shown in strips)
#' plot_ace(ace_output, colour_by = SP_CODE, facet_by = GEAR_CODE, facet_scales = "free_y")
#' }
#'
#' @importFrom rlang enquo quo_is_null as_name
#'
#' @export
plot_ace <- function(
  data,
  colour_by = NULL,
  facet_by = NULL,
  facet_scales = "fixed"
) {
  colour_by <- rlang::enquo(colour_by)
  facet_by <- rlang::enquo(facet_by)
  colour_values <- if (!rlang::quo_is_null(colour_by)) {
    pkg_colour_lookup(rlang::as_name(colour_by))
  } else {
    NULL
  }

  group_vars <- c(
    "YY",
    if (!rlang::quo_is_null(colour_by)) rlang::as_name(colour_by),
    if (!rlang::quo_is_null(facet_by)) rlang::as_name(facet_by)
  )

  plot_data <-
    data |>
    dplyr::summarise(
      sum_catch_mt = sum(sum_catch_mt),
      .by = dplyr::all_of(group_vars)
    )

  p <-
    ggplot2::ggplot(
      plot_data,
      ggplot2::aes(
        x = YY,
        y = sum_catch_mt,
        colour = !!colour_by,
        group = !!colour_by
      )
    ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point() +
    ggplot2::labs(x = NULL, y = "Catch (mt)", colour = NULL) +
    ggplot2::scale_y_continuous(
      labels = scales::label_number(scale_cut = scales::cut_short_scale())
    ) +
    theme_fishextract()

  if (!rlang::quo_is_null(facet_by)) {
    facet_lookup <- pkg_label_lookup(rlang::as_name(facet_by))
    facet_labeller <- if (!is.null(facet_lookup)) {
      ggplot2::as_labeller(facet_lookup)
    } else {
      ggplot2::label_value
    }

    p <- p +
      ggplot2::facet_wrap(
        ggplot2::vars(!!facet_by),
        scales = facet_scales,
        labeller = facet_labeller
      )
  }

  if (!is.null(colour_values)) {
    colour_lookup <- pkg_label_lookup(rlang::as_name(colour_by))
    colour_labels <- if (!is.null(colour_lookup)) {
      colour_lookup
    } else {
      ggplot2::waiver()
    }

    p <- p +
      ggplot2::scale_colour_manual(
        values = colour_values,
        labels = colour_labels
      )
  }

  p
}
