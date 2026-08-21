# plot_n_vessels <- function(
#   data,
#   colour_by = NULL,
#   facet_by = NULL,
#   facet_scales = "fixed",
#   hline = TRUE
# ) {
#   colour_by <- rlang::enquo(colour_by)
#   facet_by <- rlang::enquo(facet_by)
#   colour_values <- if (!rlang::quo_is_null(colour_by)) {
#     lookup_colour(rlang::as_name(colour_by))
#   } else {
#     NULL
#   }

#   group_vars <- c(
#     "YY",
#     if (!rlang::quo_is_null(colour_by)) rlang::as_name(colour_by),
#     if (!rlang::quo_is_null(facet_by)) rlang::as_name(facet_by)
#   )

#   plot_data <-
#     data |>
#     dplyr::summarise(
#       sum_catch_mt = sum(sp_mt),
#       .by = dplyr::all_of(group_vars)
#     )

#   p <-
#     ggplot2::ggplot(
#       plot_data,
#       ggplot2::aes(
#         x = YY,
#         y = sum_catch_mt,
#         colour = !!colour_by,
#         group = !!colour_by
#       )
#     ) +
#     ggplot2::geom_line(linewidth = 0.8) +
#     ggplot2::geom_point() +
#     ggplot2::labs(x = NULL, y = "Number of vessels", colour = NULL) +
#     ggplot2::scale_y_continuous(
#       labels = scales::label_number(scale_cut = scales::cut_short_scale())
#     ) +
#     theme_fishextract()

#   if (!rlang::quo_is_null(facet_by)) {
#     facet_lookup <- label_lookup(rlang::as_name(facet_by))
#     facet_labeller <- if (!is.null(facet_lookup)) {
#       ggplot2::as_labeller(facet_lookup)
#     } else {
#       ggplot2::label_value
#     }

#     p <- p +
#       ggplot2::facet_wrap(
#         ggplot2::vars(!!facet_by),
#         scales = facet_scales,
#         labeller = facet_labeller
#       )
#   }

#   if (!is.null(colour_values)) {
#     colour_lookup <- label_lookup(rlang::as_name(colour_by))
#     colour_labels <- if (!is.null(colour_lookup)) {
#       colour_lookup
#     } else {
#       ggplot2::waiver()
#     }

#     p <- p +
#       ggplot2::scale_colour_manual(
#         values = colour_values,
#         labels = colour_labels
#       )
#   }

#   p
# }
