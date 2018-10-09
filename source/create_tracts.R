# this script was used to create the tract boundary raw data

# tidyverse packages
library(dplyr)     # data wrangling

# spatial packages
library(sf)        # spatial data tools
library(tigris)    # download geometric data

# other packages
library(here)      # file path management

# download census tract boundaries
stlTracts <- tracts(state = 29, county = 510)

# convert to sf object
stlTracts <- st_as_sf(stlTracts)

# remove unneeded variables
stlTracts <- select(stlTracts, GEOID, TRACTCE, ALAND)

# write to raw data
st_write(stlTracts, dsn = here("data", "spatial", "raw", "STL_DEMOGRAPHICS_Tracts.shp"))
