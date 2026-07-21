plot_ace_timeseries <- function(
  ocean = NULL,
  flag = NULL,
  gear = NULL,
  species = NULL,
  year = NULL,
  group_by = c("species", "gear", "flag"),
  main_gears = NULL,
  combined_plot = FALSE
) {
  group_by <- match.arg(group_by)
  group_var <-
    dplyr::case_when(
      group_by == "species" ~ "SP_CODE",
      group_by == "gear" ~ "GEAR_CODE",
      group_by == "flag" ~ "FLAG_CODE"
    )

  input_data <-
    sum_ace(
      ocean = ocean,
      species = species,
      group_species = !("species" %in% group_by),
      group_flags = !("flag" %in% group_by),
      group_gears = !("gear" %in% group_by)
    ) |>
    dplyr::arrange(desc(YY))

  if (group_by == "gear" && !is.null(main_gears)) {
    input_data <- input_data |>
      dplyr::mutate(
        GEAR_CODE = dplyr::if_else(GEAR_CODE %in% main_gears, GEAR_CODE, "O")
      )
  }

  input_data <- input_data |>
    dplyr::summarise(
      sum_catch_mt = sum(sum_catch_mt),
      .by = c(YY, dplyr::all_of(group_var))
    )
  p <-
    input_data |>
    ggplot2::ggplot(ggplot2::aes(
      YY,
      sum_catch_mt,
      col = .data[[group_var]],
      fill = .data[[group_var]]
    )) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::labs(x = NULL, y = "Catch (mt)")

  output_plot <- p

  if (combined_plot) {
    p2 <-
      input_data |>
      dplyr::summarise(sum_catch_mt = sum(sum_catch_mt), .by = YY) |>
      ggplot2::ggplot(ggplot2::aes(
        YY,
        sum_catch_mt
      )) +
      ggplot2::geom_line(col = "black") +
      ggplot2::geom_point(col = "black") +
      ggplot2::labs(x = NULL, y = "Catch (mt)")
    output_plot <-
      patchwork::wrap_plots(p, p2)
  }
  return(output_plot)
}
