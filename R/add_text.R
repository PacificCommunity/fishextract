add_text <- function(
  plot,
  type,
  colour = "red",
  size = 5,
  ...
) {
  text <- .mapping_text(type)

  plot +
    ggplot2::geom_text(
      data = text,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
      colour = colour,
      size = size,
      inherit.aes = FALSE,
      ...
    )
}
