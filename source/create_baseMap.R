# this script was used to create basemap shapefiles stored in `data/spatial/baseMap`

# tidyverse packages

# spatial packages
library(sf)
library(tigris)

# other packages
library(here)


# county boundary
## download data
mo <- counties(state = 29)
mo <- st_as_sf(mo)
city <- filter(mo, COUNTYFP == "510")
rm(mo)

# interstate highways
## download data
roads <- primary_roads()
roads <- st_as_sf(roads)
city_hwys <- st_intersection(roads, city)
city_hwys <- filter(city_hwys, RTTYP == "I")
rm(roads)

# write data
save(city, city_hwys, file = here("data", "spatial", "baseMap", "baseMap.rda"))

# clean enviornment
rm(list = ls())
