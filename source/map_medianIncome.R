# this script was used to create the map of median income by tract saved in `results/maps/medianIncome.png`

# tidyverse packages
library(dplyr)
library(ggplot2)

# spatial packages
library(sf)
library(tidycensus)
library(tigris)

# other packages
library(here)
library(prener)

# download income data
medianInc <- get_acs("tract", variable = "B19019_001", state = 29, county = 510)

# clean income data
medianInc %>%
  select(GEOID, estimate) %>%
  rename(medianInc = estimate) %>%
  cp_breaks(var = medianInc, newvar = incJenks, classes = 5, style = "jenks") -> incJenks

# download/load needed spatial data
## load county boundary
city <- st_read(here("data", "spatial", "baseMap", "STL_BOUNDARY_City.shp"), stringsAsFactors = FALSE)

## download interstate highways
roads <- primary_roads()
roads <- st_as_sf(roads)
city_hwys <- st_intersection(roads, city)
city_hwys <- filter(city_hwys, RTTYP == "I")
rm(roads)

## load tract boundaries
tracts <- st_read(here("data", "spatial", "raw", "STL_DEMOGRAPHICS_Tracts.shp"), stringsAsFactors = FALSE)

# merge income and tract data
tracts <- left_join(tracts, incJenks, by = "GEOID")

# map median income
ggplot() +
  geom_sf(data = tracts, mapping = aes(fill = incJenks), color = "#A6AAA9") +
  geom_sf(data = city_hwys, mapping = aes(color = "Highways"), size = 1.5, fill = NA) +
  geom_sf(data = city, fill = NA, color = "#000000", size = .25) +
  scale_fill_brewer(palette = "RdPu", name = "Median Income",
                    labels = c("< $23,200", "$23,200 - $33,900", "$33,900 - $46,900", "$46,900 - $58,500", "> $58,500")) +
  scale_colour_manual(name="", values= "black") +
  labs(
    title = "Median Household Income",
    subtitle = "Census Tract Data for 2012-2016 ACS"
  ) +
  cp_sequoiaTheme(background = "transparent", map = TRUE)

# save plot
cp_plotSave(filename = here("results", "maps", "medianIncome.png"), preset = "lg", dpi = 500)

# clean workspace
rm(list = ls())
