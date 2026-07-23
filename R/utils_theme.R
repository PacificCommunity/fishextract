#' Package plotting theme
#'
#' A consistent \pkg{ggplot2} theme used across all plotting functions in
#' this package. Built on \code{\link[ggplot2]{theme_minimal}}, with minor
#' gridlines removed, shaded facet strips, and the legend placed below the
#' plot.
#'
#' @param base_size Base font size, in points. Defaults to 11.
#'
#' @return A \code{ggplot2} theme object that can be added to a
#'   \code{ggplot} using \code{+}.
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   theme_fishextract()
#'
#' @importFrom ggplot2 %+replace%
#' @export
theme_fishextract <- function(base_size = 14) {
  ggplot2::theme_minimal(base_size = base_size) %+replace%
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      strip.background = ggplot2::element_rect(fill = "white", colour = NA),
      legend.position = "bottom"
    )
}
