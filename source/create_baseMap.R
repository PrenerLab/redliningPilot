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

## write data
st_write(city, dsn = here("data", "spatial", "baseMap", "STL_BOUNDARY_City.shp"))

# interstate highways
## download data
roads <- primary_roads()
roads <- st_as_sf(roads)
city_hwys <- st_intersection(roads, city)
city_hwys <- filter(city_hwys, RTTYP == "I")
city_hwys <- st_cast(city_hwys, to = "MULTIPOINT")
rm(roads)

ggplot() +
  geom_sf(data = city_hwys, mapping = aes(color = "Highways"), size = 1.5, fill = NA)


## write data
st_write(city_hwys, dsn = here("data", "spatial", "baseMap", "STL_TRANS_Interstates.shp"))
