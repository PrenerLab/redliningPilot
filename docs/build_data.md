Build Data Set
================
Christopher Prener, Ph.D.
(October 18, 2018)

## Introduction

This notebook builds the analytical data set from the results of
`redlining_area.Rmd`, CDC data, and demographic data.

## Dependencies

This notebook requires a number of packages:

``` r
# tidyverse packages
library(dplyr)         # data wrangling
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
library(readr)

# other packages
library(cityHealth)    # CDC data
library(here)          # file path management
```

    ## here() starts at /Users/chris/GitHub/Lab/redliningPilot

``` r
library(sf)            # spatial tools
```

    ## Linking to GEOS 3.6.1, GDAL 2.1.3, proj.4 4.9.3

``` r
library(tidycensus)    # demographic data
library(tidyseg)       # tidy segregation tools
```

## Load Data

This notebook requires the redlining data already calculated for
St. Louis:

``` r
redlining <- read_csv(here("data", "redlining", "STL_REDLINING_cdGrade.csv"))
```

    ## Parsed with column specification:
    ## cols(
    ##   GEOID = col_double(),
    ##   cGrade = col_double(),
    ##   dGrade = col_double(),
    ##   cdGrade = col_double(),
    ##   ALAND = col_integer()
    ## )

``` r
redlining <- mutate(redlining, GEOID = as.character(GEOID))
```

## Demographic Data

The first goal of this notebook is to download and prepare for joining
all of the needed demographic data.

### Race

Count of *individuals* for each racial identity, recoded into estimates
for white, black, and other per census tract. This means we lose the
margin of error for other
race.

``` r
race <- get_acs(geography = "tract", table = "B02001", state = 29, county = 510, 
                     year = 2016, output = "wide")
```

    ## Getting data from the 2012-2016 5-year ACS

``` r
race %>%
  rename(totalPop = B02001_001E) %>%
  rename(totalPop_m = B02001_001M) %>%
  rename(white = B02001_002E) %>%
  rename(white_m = B02001_002M) %>%
  rename(black = B02001_003E) %>%
  rename(black_m = B02001_003M) %>%
  mutate(otherRace = totalPop-white-black) %>%
  select(GEOID, totalPop, totalPop_m, white, white_m, black, black_m, otherRace) -> race
```

### Median Income

Median *household* income per census
tract.

``` r
medianInc <- get_acs(geography = "tract", variables = "B19019_001", state = 29, county = 510, 
                     year = 2016, output = "wide")
```

    ## Getting data from the 2012-2016 5-year ACS

``` r
medianInc %>%
  select(-NAME) %>%
  rename(medianInc = B19019_001E) %>%
  rename(medianInc_m = B19019_001M) -> medianInc
```

### Poverty Status

Poverty status for the total number of *individuals* per census
tract.

``` r
poverty <- get_acs(geography = "tract", variables = "B17001_002", state = 29, county = 510, 
                     year = 2016, output = "wide")
```

    ## Getting data from the 2012-2016 5-year ACS

``` r
poverty %>%
  select(-NAME) %>%
  rename(poverty = B17001_002E) %>%
  rename(poverty_m = B17001_002M) -> poverty
```

We also download an estimate for the African American poverty rate -
this is also at the *individuals*
level.

``` r
povertyB <- get_acs(geography = "tract", variables = "B17001B_002", state = 29, county = 510, 
                     year = 2016, output = "wide")
```

    ## Getting data from the 2012-2016 5-year ACS

``` r
povertyB %>%
  select(-NAME) %>%
  rename(povertyB = B17001B_002E) %>%
  rename(povertyB_m = B17001B_002M) -> povertyB
```

### Social Services

Additionally, we get a count of the number of *individuals* served by
Medicaid per census tract. This is the sum of a number of columns, so
margins of error are not
retained.

``` r
medicaid <- get_acs(geography = "tract", table = "C27007", state = 29, county = 510, 
                     year = 2016, output = "wide")
```

    ## Getting data from the 2012-2016 5-year ACS

``` r
medicaid %>%
  mutate(medicaid = C27007_004E + C27007_007E + C27007_010E + C27007_014E + C27007_017E + C27007_020E) %>%
  select(GEOID, medicaid) -> medicaid
```

We can add to this a number of *household* level measures, including
TANF
reciepency.

``` r
tanf <- get_acs(geography = "tract", table = "B19057", state = 29, county = 510, 
                     year = 2016, output = "wide")
```

    ## Getting data from the 2012-2016 5-year ACS

``` r
tanf %>%
  rename(house = B19057_001E) %>%
  rename(house_m = B19057_001M) %>%
  rename(tanf = B19057_002E) %>%
  rename(tanf_m = B19057_002M) %>%
  mutate(tanfProp = tanf/house) %>%
  select(GEOID, house, house_m, tanf, tanf_m, tanfProp) -> tanf
```

SNAP benefit counts per *household* are also included, though there is
some recent work that suggests this is dramatically under reported in
the
CPS.

``` r
snap <- get_acs(geography = "tract", table = "B19058", state = 29, county = 510, 
                     year = 2016, output = "wide")
```

    ## Getting data from the 2012-2016 5-year ACS

``` r
snap %>%
  rename(snap = B19058_002E) %>%
  rename(snap_m = B19058_002M) %>%
  mutate(snapProp = snap/B19058_001E) %>%
  select(GEOID, snap, snap_m, snapProp) -> snap
```

Finally, we get ownership and rental data from
*households*:

``` r
tenure <- get_acs(geography = "tract", table = "B25003", state = 29, county = 510, 
                     year = 2016, output = "wide")
```

    ## Getting data from the 2012-2016 5-year ACS

``` r
tenure %>%
  rename(own = B25003_002E) %>%
  rename(own_m = B25003_002M) %>%
  mutate(ownProp = own/B25003_001E) %>%
  rename(rent = B25003_003E) %>%
  rename(rent_m = B25003_003M) %>%
  mutate(rentProp = rent/B25003_001E) %>%
  select(GEOID, own, own_m, ownProp, rent, rent_m, rentProp) -> tenure
```

## CDC Data

The CDC data that we want also contains margin of error in formation,
but we need to subset it first both by observations and columns to
remove all non-St. Louis and all outcomes other than asthma, obesity,
and dental. We also retain the percent of individuals who do not have
health insurance to control for variation there.

``` r
# subset data for City of St. Louis and trim number of columns
ch_tbl_tract17 %>%
  filter(city_fips == 2965000) %>%
  select(tract_fips, category, question, estimate, estimate_ci_low, estimate_ci_high) %>%
  rename(GEOID = tract_fips) -> cdc_stl
```

First, we create a single table for current asthma:

``` r
cdc_stl %>%
  filter(question == "Current Asthma") %>%
  select(GEOID, estimate, estimate_ci_low, estimate_ci_high) %>% 
  rename(asthma = estimate) %>%
  rename(asthma_ml = estimate_ci_low) %>%
  rename(asthma_mh = estimate_ci_high) -> asthma
```

We also create a table for obesity as a risk factor:

``` r
cdc_stl %>%
  filter(question == "Obesity") %>%
  select(GEOID, estimate, estimate_ci_low, estimate_ci_high) %>% 
  rename(obesity = estimate) %>%
  rename(obesity_ml = estimate_ci_low) %>%
  rename(obesity_mh = estimate_ci_high) -> obesity
```

And a measure of dental service utilization:

``` r
cdc_stl %>%
  filter(question == "Dental Visit") %>%
  select(GEOID, estimate, estimate_ci_low, estimate_ci_high) %>% 
  rename(dental = estimate) %>%
  rename(dental_ml = estimate_ci_low) %>%
  rename(dental_mh = estimate_ci_high) -> dental
```

Finally, we’ll use the percent of individuals missing health insurance
as an independent variable:

``` r
cdc_stl %>%
  filter(question == "Health Insurance") %>%
  select(GEOID, estimate, estimate_ci_low, estimate_ci_high) %>% 
  rename(unins = estimate) %>%
  rename(unins_ml = estimate_ci_low) %>%
  rename(unins_mh = estimate_ci_high) -> unins
```

## Combine Data

With all data downloaded, we combine the tables together and calculate
the remaining proportions.

``` r
analysis <- left_join(redlining, race, by = "GEOID")

analysis %>%
  left_join(y = medianInc, by = "GEOID") %>%
  left_join(y = poverty, by = "GEOID") %>%
  left_join(y = povertyB, by = "GEOID") %>%
  left_join(y = medicaid, by = "GEOID") %>%
  left_join(y = tanf, by = "GEOID") %>%
  left_join(y = snap, by = "GEOID") %>%
  left_join(y = tenure, by = "GEOID") %>%
  left_join(y = unins, by = "GEOID") %>%
  left_join(y = asthma, by = "GEOID") %>%
  left_join(y = obesity, by = "GEOID") %>%
  left_join(y = dental, by = "GEOID") -> analysis

analysis %>%
  mutate(whiteProp = white/totalPop) %>%
  mutate(blackProp = black/totalPop) %>%
  mutate(otherRaceProp = otherRace/totalPop) %>%
  mutate(povertyProp = poverty/totalPop) %>%
  mutate(povertyBProp = povertyB/totalPop) %>%
  mutate(medicaidProp = medicaid/totalPop) %>%
  mutate(uninsProp = unins/100) %>%
  mutate(asthmaProp = asthma/100) %>%
  mutate(obesityProp = obesity/100) %>%
  mutate(dentalProp = dental/100) -> analysis
```

With proportions in hand, we also need to caclulate the index of
dissimilarity information for
St. Louis:

``` r
analysis <- ts_dissim(analysis, popA = white, popB = black, dissim = dissim, return = "tibble")
ts_dissim(analysis, popA = white, popB = black, return = "index")
```

    ## [1] 0.6148765

We create a full analysis data set with all margin of error information
(where available):

``` r
analysis <- select(analysis, GEOID, ALAND, cGrade, dGrade, cdGrade, 
                   totalPop, totalPop_m, house, house_m,
                   white, white_m, whiteProp, black, black_m, blackProp, otherRace, otherRaceProp,
                   dissim,
                   medianInc, medianInc_m,
                   poverty, poverty_m, povertyProp, 
                   povertyB, povertyB_m, povertyBProp, 
                   medicaid, medicaidProp, 
                   tanf, tanf_m, tanfProp, 
                   snap, snap_m, snapProp, 
                   own, own_m, ownProp, rent, rent_m, rentProp, 
                   unins, unins_ml, unins_mh, uninsProp, 
                   asthma, asthma_ml, asthma_mh, asthmaProp, 
                   obesity, obesity_ml, obesity_mh, obesityProp,
                   dental, dental_ml, dental_mh, dentalProp)

write_csv(analysis, path = here("data", "merged", "merged_full.csv"))
```

And a slimmed down version that will be merged with the spatial
data:

``` r
analysisSlim <- select(analysis, GEOID, cdGrade, whiteProp, blackProp, otherRaceProp, dissim, medianInc, 
                       povertyProp, povertyBProp, medicaidProp, tanfProp, snapProp, rentProp, 
                       uninsProp, asthmaProp, obesityProp, dentalProp)

write_csv(analysisSlim, path = here("data", "merged", "merged_slim.csv"))
```

To create that spatial data set, we import the previous cleaned tract
data:

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

And we rename all variables to be compatible with ESRI shapefile
standards before writing the file itself:

``` r
analysisSlim %>%
  rename(CDGRADE = cdGrade) %>%
  rename(WHITE = whiteProp) %>%
  rename(BLACK = blackProp) %>%
  rename(OTHERRACE = otherRaceProp) %>%
  rename(DISSIM = dissim) %>%
  rename(MEDINC = medianInc) %>%
  rename(POVERTY = povertyProp) %>%
  rename(POVERTYB = povertyBProp) %>%
  rename(MEDICAID = medicaidProp) %>%
  rename(TANF = tanfProp) %>%
  rename(SNAP = snapProp) %>%
  rename(RENT = rentProp) %>%
  rename(UNINS = uninsProp) %>%
  rename(ASTHMA = asthmaProp) %>%
  rename(OBESITY = obesityProp) %>%
  rename(DENTAL = dentalProp) -> analysis_preSpatial

tractsComplete <- left_join(tracts, analysis_preSpatial, by = "GEOID")

st_write(tractsComplete, here("data", "spatial", "clean", "STL_REDLINING_Analysis.shp"))
```

    ## Writing layer `STL_REDLINING_Analysis' to data source `/Users/chris/GitHub/Lab/redliningPilot/data/spatial/clean/STL_REDLINING_Analysis.shp' using driver `ESRI Shapefile'
    ## features:       106
    ## fields:         19
    ## geometry type:  Polygon
