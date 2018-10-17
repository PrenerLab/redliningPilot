Calculate Redlining Area
================
Christopher Prener, Ph.D.
(October 17, 2018)

## Introduction

This notebook creates measures of the impact of redlining by census
tract. Two measures are calculated - the square meters of Class ‘C’
(yellow, or declining areas) and the square meters of Class ‘D’ (red, or
minority/immigrant areas).

## Dependencies

This notebook requires data from the `data/` directory as well as the
`sf` and `dplyr` packages.

``` r
# project package
library(redHealth)

# tidyverse packages
library(dplyr)      # data wrangling
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(ggplot2)    # data plotting
library(readr)      # csv tools

# spatial packages
library(sf)         # spatial data tools
```

    ## Linking to GEOS 3.6.1, GDAL 2.1.3, proj.4 4.9.3

``` r
# other packages
library(here)       # file path management
```

    ## here() starts at /Users/chris/GitHub/Lab/redliningPilot

``` r
library(prener)     # plot themes
```

## Load Data

This notebook requires the raw redlining data and the census tract
boundary
data.

``` r
redRaw <- st_read(here("data", "redlining", "raw", "HOLC_St.shp"), stringsAsFactors = FALSE)
```

    ## Reading layer `HOLC_St' from data source `/Users/chris/GitHub/Lab/redliningPilot/data/redlining/raw/HOLC_St.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 126 features and 4 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: -90.39063 ymin: 38.52039 xmax: -90.18671 ymax: 38.75724
    ## epsg (SRID):    4326
    ## proj4string:    +proj=longlat +datum=WGS84 +no_defs

``` r
tracts <- st_read(here("data", "spatial", "raw", "STL_DEMOGRAPHICS_Tracts.shp"), stringsAsFactors = FALSE)
```

    ## Reading layer `STL_DEMOGRAPHICS_Tracts' from data source `/Users/chris/GitHub/Lab/redliningPilot/data/spatial/raw/STL_DEMOGRAPHICS_Tracts.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 106 features and 3 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: -90.32052 ymin: 38.53185 xmax: -90.16657 ymax: 38.77443
    ## epsg (SRID):    NA
    ## proj4string:    +proj=longlat +ellps=GRS80 +no_defs

``` r
load(here("data", "spatial", "baseMap", "baseMap.rda"))
```

## Update CRS for Tract Data

We want both data sets to have matching `crs` values - the tract data
are therefore updates to EPSG `4326`:

``` r
city <- st_transform(city, crs = 4326)
city_hwys <- st_transform(city_hwys, crs = 4326)
tracts <- st_transform(tracts, crs = 4326)
```

They can now be used for geometric operations with the `redRaw` data.

## Pre-Process and Map the Redlining Zones

``` r
redClean <- select(redRaw, -city, -name)
redClean <- st_intersection(redClean, city)
```

    ## although coordinates are longitude/latitude, st_intersection assumes that they are planar

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
source(here("source", "map_zones.R"))
```

## Clean Redlining Data

The first step is to remove unneeded columns and unneeded observations
from the `redRaw` sf object:

``` r
redClean %>% 
  filter(holc_grade == "C" | holc_grade == "D") -> cdAreas
```

Next, we want to calculate the area of each census tract that is covered
by both “C” and “D” graded
    zones:

``` r
cAreas <- rh_area(tract = tracts, holc = cdAreas, cat = "C")
```

    ## although coordinates are longitude/latitude, st_intersection assumes that they are planar

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

``` r
dAreas <- rh_area(tract = tracts, holc = cdAreas, cat = "D")
```

    ## although coordinates are longitude/latitude, st_intersection assumes that they are planar

    ## Warning: attribute variables are assumed to be spatially constant
    ## throughout all geometries

With the areas calculated, we fold them back into a geometric object
named `redAreas`, sum them, and get the percent of each tract that was
redlined as either “C” or “D”
grade.

``` r
redAreas <- rh_area_join(tract = tracts, area = cAreas, by = "GEOID", cat = "cGrade")
redAreas <- rh_area_join(tract = redAreas, area = dAreas, by = "GEOID", cat = "dGrade")

redAreas %>% 
  mutate(cdGrade = cGrade+dGrade) %>%
  mutate(cdPct = (cdGrade/as.numeric(ALAND))*100) -> redAreas
```

Next, we want to create an initial map:

``` r
source(here("source", "map_cdPct.R"))
```

## Export Redlining Data

Finally, we’re write these data to a `csv` file.

``` r
st_geometry(redAreas) <- NULL

redAreas %>%
  select(GEOID, cGrade, dGrade, cdGrade, ALAND) %>%
  write_csv(x = ., path = here("data", "redlining", "STL_REDLINING_cdGrade.csv"))
```

This gives us a basis for our analysis.
