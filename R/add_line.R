add_line <- function(
  plot,
  type,
  colour = "red",
  linewidth = 0.8,
  linetype = "solid"
) {
  layer <- ggplot2::geom_path(
    data = .mapping_lines(type),
    ggplot2::aes(x = x, y = y),
    colour = colour,
    linewidth = linewidth,
    linetype = linetype,
    inherit.aes = FALSE
  )

  plot$layers <- append(plot$layers, list(layer), after = 0)

  plot
}
