#  updates the description file with the packages that are used in the package
attachment::att_from_rscripts() |>
    purrr::walk(usethis::use_package, min_version = TRUE)

devtools::document()
devtools::build()
devtools::test()
