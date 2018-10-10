# this script was used to create the map of % african american by tract saved in `results/maps/race.png`

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

# download race data
race <- get_acs("tract", table = "B02001", state = 29, county = 510, output = "wide")

# clean race data
race %>%
  select(GEOID, B02001_001E, B02001_003E) %>%
  mutate(pctBlack = (B02001_003E/B02001_001E)*100) %>%
  select(GEOID, pctBlack) %>%
  cp_breaks(var = pctBlack, newvar = blackJenks, classes = 5, style = "jenks") -> pctBlack

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

# merge race and tract data
tracts <- left_join(tracts, pctBlack, by = "GEOID")

# map race
ggplot() +
  geom_sf(data = tracts, mapping = aes(fill = blackJenks), color = "#A6AAA9") +
  geom_sf(data = city_hwys, mapping = aes(color = "Highways"), size = 1.5, fill = NA) +
  geom_sf(data = city, fill = NA, color = "#000000", size = .25) +
  scale_fill_brewer(palette = "BuPu", name = "Percent",
                    labels = c("< 14.2", "14.2 - 32.6", "32.6 - 49.3", "49.3 - 79.0", "> 79.0")) +
  scale_colour_manual(name="", values= "black") +
  labs(
    title = "African American Population",
    subtitle = "Census Tract Data for 2012-2016 ACS"
  ) +
  cp_sequoiaTheme(background = "transparent", map = TRUE)

# save plot
cp_plotSave(filename = here("results", "maps", "race.png"), preset = "lg", dpi = 500)

# clean workspace
rm(list = ls())
