.extract_eez <- function() {
  wcpfc_members <- c(
    "Australia",
    "Canada",
    "China",
    "Cook Islands",
    "France",
    "Micronesia",
    "Fiji",
    "South Korea",
    "Marshall Islands",
    "Nauru",
    "New Zealand",
    "Niue",
    "Palau",
    "Papua New Guinea",
    "Philippines",
    "Samoa",
    "Solomon Islands",
    "Taiwan",
    "Tonga",
    "Tuvalu",
    "United States",
    "Vanuatu",
    "Indonesia",
    "Phoenix Group", # Kiribati
    "Gilbert Islands", # Kiribati
    "Line Group" # Kiribati
  )

  wcpfc_territories <- c(
    "American Samoa",
    "French Polynesia",
    "Guam",
    "New Caledonia",
    "Northern Mariana Islands",
    "Tokelau",
    "Wallis and Futuna"
  )

  wcpfc_cnm <- c(
    "Belize",
    "Ecuador",
    "El Salvador",
    "Mexico",
    "Senegal",
    "Vietnam"
  )

  wcpfc_all <- c(wcpfc_members, wcpfc_territories, wcpfc_cnm)

  # at some point we should use the following (although currently only for PICTs)
  # https://geonode.pacificdata.org/catalogue/#/dataset/1579
  wcpfc_eez <-
    "G:/Info_dbs/MapTabs/Boundaries/EEZ_VLIZ/VLIZ-v10/World_EEZ_v10_2018_0_360.shp" |>
    sf::st_read() |>
    dplyr::filter(Territory1 %in% wcpfc_all)

  wcpfc_eez_simplified <-
    wcpfc_eez |>
    sf::st_simplify(dTolerance = 1000, preserveTopology = TRUE) |>
    sf::st_wrap_dateline(
      options = c("WRAPDATELINE=YES", "DATELINEOFFSET=180")
    ) |>
    sf::st_shift_longitude()

  usethis::use_data(
    wcpfc_eez_simplified,
    compress = "xz",
    internal = TRUE,
    overwrite = TRUE
  )
}
