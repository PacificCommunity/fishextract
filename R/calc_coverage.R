calc_coverage <-
  function(
    in_wcpfc = NULL,
    flag = NULL,
    gear = NULL,
    species = NULL,
    year = NULL,
    group_species = FALSE
  ) {
    ace_catch <-
      sum_ace(
        ocean = if (is.null(in_wcpfc)) NULL else "WX",
        flag = flag,
        gear = gear,
        species = species,
        year = year,
        group_species = group_species
      ) |>
      dplyr::rename(ace_catch = sum_catch_mt) |>
      dplyr::select(-any_of("OCEAN_CODE"))

    logbook_catch <-
      logbook_catch(
        in_wcpfc = in_wcpfc,
        flag = flag,
        gear = gear,
        species = species,
        year = year
      ) |>
      dplyr::rename(logbook_catch = sp_mt)

    joined_catch <-
      ace_catch |>
      dplyr::full_join(logbook_catch) |>
      dplyr::mutate(
        ace_catch = tidyr::replace_na(ace_catch, 0),
        logbook_catch = tidyr::replace_na(logbook_catch, 0)
      )

    if (group_species) {
      joined_catch_spp <-
        joined_catch |>
        dplyr::summarise(
          logbook_catch = sum(logbook_catch),
          .by = -SP_CODE
        )
    } else {
      joined_catch_spp <- joined_catch
    }

    joined_catch_spp |>
      dplyr::mutate(
        coverage = (ace_catch - logbook_catch) / ace_catch
      )

    return(logbook_catch)
  }
# calc_coverage(TRUE)
# xx <-
#   logbook_catch(
#     in_wcpfc = TRUE,
#     flag = NULL,
#     species = NULL,
#     year = NULL
#   ) |>
#   dplyr::rename(logbook_catch = sp_mt)
# yy <- sum_ace(
#   ocean = if (is.null(TRUE)) NULL else "WX",
#   flag = NULL,
#   species = NULL,
#   year = NULL
# ) |>
#   dplyr::rename(ace_catch = sum_catch_mt) |>
#   dplyr::select(-any_of("OCEAN_CODE"))

# xx |>
#   dplyr::full_join(yy) |>
#   dplyr::mutate(
#     ace_catch = tidyr::replace_na(ace_catch, 0),
#     logbook_catch = tidyr::replace_na(logbook_catch, 0)
#   )
