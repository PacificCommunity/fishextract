#  updates the description file with the packages that are used in the package
attachment::att_from_rscripts() |>
    purrr::walk(usethis::use_package, min_version = TRUE)

devtools::document()
devtools::build()
devtools::test()

utils::remove.packages("purrr")
utils::remove.packages("fishextract")
remotes::install_github("PacificCommunity/fishextract")
