# Tuna RFMO convention areas on a flat, Pacific-centred map
# Boundaries: FAO Regional Fishery Bodies WFS (fao.org/fishery/geoserver) — © FAO

library(tidyverse)
library(sf)
library(httr2)
library(maps) # for the world2 (0-360°) basemap

# ---- 1. Tuna RFMOs: acronym, full name, FAO WFS layer name -----------------
tuna_rfmo <- tribble(
  ~acronym , ~full_name                                                        , ~wfs_layer  ,
  "ICCAT"  , "International Commission for the Conservation of Atlantic Tunas" , "RFB_ICCAT" ,
  "IATTC"  , "Inter-American Tropical Tuna Commission"                         , "RFB_IATTC" ,
  "IOTC"   , "Indian Ocean Tuna Commission"                                    , "RFB_IOTC"  ,
  "WCPFC"  , "Western and Central Pacific Fisheries Commission"                , "RFB_WCPFC" ,
  "CCSBT"  , "Commission for the Conservation of Southern Bluefin Tuna"        , "RFB_CCSBT"
) %>%
  mutate(acronym = fct_inorder(acronym))

# ---- 2. Pull each convention area from the FAO Geoserver WFS ---------------
# NB if a layer comes back empty, check the exact name via:
# https://www.fao.org/fishery/geoserver/rfb/ows?service=WFS&request=GetCapabilities
fao_wfs_url <- function(layer) {
  paste0(
    "https://www.fao.org/fishery/geoserver/rfb/ows?service=WFS&",
    "request=GetFeature&version=1.0.0&typeName=",
    layer,
    "&outputFormat=json"
  )
}

fetch_rfmo <- function(layer) {
  json <- tryCatch(
    httr2::request(fao_wfs_url(layer)) %>%
      httr2::req_user_agent("mozilla/5.0 (r/sf tuna-rfmo-map)") %>%
      httr2::req_perform() %>%
      httr2::resp_body_string(),
    error = function(e) {
      stop(
        "FAO WFS request failed for ",
        layer,
        ": ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  st_read(json, quiet = TRUE) %>%
    st_make_valid() %>%
    st_union() %>%
    st_sf(geometry = .)
}

rfmo_sf <- tuna_rfmo %>%
  mutate(geom_sf = purrr::map(wfs_layer, fetch_rfmo)) %>%
  select(-wfs_layer) %>%
  unnest(geom_sf) %>%
  st_as_sf(crs = st_crs(4326))

# ---- 3. Flat basemap, Pacific-centred via maps::world2 ---------------------
# world2 is stored in 0-360° longitude, so it's naturally Pacific-centred
# with no antimeridian splitting needed — shift the RFMO polygons to match.
world2 <- st_as_sf(maps::map("world2", plot = FALSE, fill = TRUE)) %>%
  st_set_crs(4326)

rfmo_flat <- rfmo_sf %>% st_shift_longitude()

# ---- 4. Map -----------------------------------------------------------------
legend_labels <- with(tuna_rfmo, paste0(acronym, " \u2013 ", full_name)) %>%
  set_names(tuna_rfmo$acronym)

ggplot() +
  geom_sf(data = world2, colour = "grey50", fill = "grey84", linewidth = 0.1) +
  geom_sf(
    data = rfmo_flat,
    aes(fill = acronym),
    colour = "white",
    alpha = 0.65,
    linewidth = 0.2
  ) +
  scale_fill_brewer(
    palette = "Set2",
    name = "Tuna RFMO",
    labels = legend_labels
  ) +
  coord_sf() +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 7.5),
    axis.text = element_blank(),
    panel.grid = element_line(colour = "grey88")
  ) +
  guides(fill = guide_legend(ncol = 1)) +
  labs(
    title = "The five tuna Regional Fisheries Management Organisations",
    caption = "Boundaries: \u00a9 FAO, FAO Regional Fishery Bodies (fao.org/fishery/geoserver)"
  )
