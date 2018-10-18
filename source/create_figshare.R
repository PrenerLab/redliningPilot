# Create figshare data

sf::st_geometry(tracts) <- NULL

readr::write_csv(tracts, here::here("data", "spatial", "clean", "STL_REDLINING_Analysis.csv"))
