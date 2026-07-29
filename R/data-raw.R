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

  wcpfc_eez <-
    "G:/Info_dbs/MapTabs/Boundaries/EEZ_VLIZ/VLIZ-v10/World_EEZ_v10_2018_0_360.shp" |>
    sf::st_read() |>
    dplyr::filter(Territory1 %in% wcpfc_all)

  wcpfc_eez_simplified <-
    wcpfc_eez |>
    sf::st_transform(3832) |> # WGS 84 / Pacific-centred, metres
    sf::st_simplify(dTolerance = 1000, preserveTopology = TRUE) |>
    sf::st_transform(sf::st_crs(wcpfc_eez)) |>
    sf::st_as_sf()

  usethis::use_data(
    wcpfc_eez_simplified,
    compress = "xz",
    internal = TRUE,
    overwrite = TRUE
  )
}
