Map and Plot Data
================
Christopher Prener, Ph.D.
(October 18, 2018)

## Introduction

This notebook creates the analytical maps and plots used in my
presentation of the pilot work in Boston in October 2018.

## Dependencies

This notebook requires a number of packages for plotting data:

``` r
# tidyverse packages
library(dplyr)       # data wrangling
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
library(ggplot2)     # data plotting

# other packages
library(here)        # file path management
```

    ## here() starts at /Users/chris/GitHub/Lab/redliningPilot

``` r
library(prener)      # data plotting
library(sf)          # mapping
```

    ## Linking to GEOS 3.6.1, GDAL 2.1.3, proj.4 4.9.3

## Load Data

This notebook requires the analysis shapefile created by
`build_data.Rmd`:

``` r
tracts <- st_read(here("data", "spatial", "clean", "STL_REDLINING_Analysis.shp"), stringsAsFactors = FALSE)
```

    ## Reading layer `STL_REDLINING_Analysis' from data source `/Users/chris/GitHub/Lab/redliningPilot/data/spatial/clean/STL_REDLINING_Analysis.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 106 features and 19 fields
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

## Additional Data Cleaning

We did not create a proportional measure for redlining, so that is
created
here:

``` r
tracts <- mutate(tracts, CDPROP = CDGRADE/as.numeric(ALAND))
```

## Plots

### Race and Redlining

``` r
dissimJenks <- cp_breaks(tracts, var = DISSIM, newvar = DJENKS, classes = 5, style = "jenks")

ggplot() +
  geom_sf(data = dissimJenks, mapping = aes(fill = DJENKS), color = "#A6AAA9") +
  geom_sf(data = city_hwys, mapping = aes(color = "Highways"), size = 1.5, fill = NA) +
  geom_sf(data = city, fill = NA, color = "#000000", size = .25) +
  scale_fill_brewer(palette = "RdBu", name = "Dissimilarity",
                    labels = c("< -0.016", "-0.016 - -0.004", "-0.004 - 0.009", "0.009 - 0.021", "> 0.021")) +
  scale_colour_manual(name="", values= "black") +
  labs(
    title = " ",
    subtitle = "Segregation"
  ) +
  cp_sequoiaTheme(background = "transparent", map = TRUE)
```

![](map_data_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

``` r
# save plot
cp_plotSave(filename = here("results", "maps", "dissim.png"), preset = "lg", dpi = 500)
```

``` r
subtitle <- expression(paste("Pearson's ", italic("r"), " = 0.286, ", italic("p"), " = .003"))

ggplot(data = tracts, mapping = aes(x = BLACK, y = CDPROP)) + 
  geom_point(position = "jitter", shape = 21, fill = "#349E8B", size = 4) + 
  geom_smooth(method = lm, color = "#E16033", size = 2) +
  labs(
    title = "Redlining and Race per Census Tract",
    subtitle = subtitle,
    x = "Proportion African American",
    y = "Proportion C or D Grade"
  ) +
  cp_sequoiaTheme(background = "gray")
```

![](map_data_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r
# save plot
cp_plotSave(filename = here("results", "figures", "redliningRace.png"), preset = "lg", dpi = 500)
```

``` r
subtitle <- expression(paste("Pearson's ", italic("r"), " = -0.272, ", italic("p"), " = 0.005"))

ggplot(data = tracts, mapping = aes(x = DISSIM, y = CDPROP)) + 
  geom_point(position = "jitter", shape = 21, fill = "#349E8B", size = 4) + 
  geom_smooth(method = lm, color = "#E16033", size = 2) +
  labs(
    title = "Redlining and Dissimilarity per Census Tract",
    subtitle = subtitle,
    x = "Index of Dissimilarity",
    y = "Proportion C or D Grade",
    caption = "Negative dissimilarity values indicate segregated black neighborhoods."
  ) +
  cp_sequoiaTheme(background = "gray")
```

![](map_data_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
# save plot
cp_plotSave(filename = here("results", "figures", "redliningDissimilarity.png"), preset = "lg", dpi = 500)
```

### Redlining and Poverty

``` r
subtitle <- expression(paste("Pearson's ", italic("r"), " = 0.432, ", italic("p"), " < 0.001"))

ggplot(data = tracts, mapping = aes(x = POVERTY, y = CDPROP)) + 
  geom_point(position = "jitter", shape = 21, fill = "#349E8B", size = 4) + 
  geom_smooth(method = lm, color = "#E16033", size = 2) +
  labs(
    title = "Redlining and Poverty per Census Tract",
    subtitle = subtitle,
    x = "Proportion of Individuals Below Poverty Line",
    y = "Proportion C or D Grade"
  ) +
  cp_sequoiaTheme(background = "gray")
```

![](map_data_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

``` r
# save plot
cp_plotSave(filename = here("results", "figures", "redliningPoverty.png"), preset = "lg", dpi = 500)
```

### Redlining and Asthma

``` r
subtitle <- expression(paste("Pearson's ", italic("r"), " = 0.328, ", italic("p"), " = 0.001"))

ggplot(data = tracts, mapping = aes(x = ASTHMA, y = CDPROP)) + 
  geom_point(position = "jitter", shape = 21, fill = "#349E8B", size = 4) + 
  geom_smooth(method = lm, color = "#E16033", size = 2) +
  labs(
    title = "Redlining and Asthma per Census Tract",
    subtitle = subtitle,
    x = "Proportion of Individuals with Current Asthma",
    y = "Proportion C or D Grade"
  ) +
  cp_sequoiaTheme(background = "gray")
```

![](map_data_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
# save plot
cp_plotSave(filename = here("results", "figures", "redliningAsthma.png"), preset = "lg", dpi = 500)
```

### Asthma Map

``` r
asthmaJenks <- cp_breaks(tracts, var = ASTHMA, newvar = AJENKS, classes = 5, style = "jenks")

ggplot() +
  geom_sf(data = asthmaJenks, mapping = aes(fill = AJENKS), color = "#A6AAA9") +
  geom_sf(data = city_hwys, mapping = aes(color = "Highways"), size = 1.5, fill = NA) +
  geom_sf(data = city, fill = NA, color = "#000000", size = .25) +
  scale_fill_brewer(palette = "Blues", name = "Proportion",
                    labels = c("< 0.094", "0.083 - 0.106", "0.106 - 0.121", "0.121 - 0.134", "0.134 - 0.153")) +
  scale_colour_manual(name="", values= "black") +
  labs(
    title = "Current Asthma Diagnosis"
  ) +
  cp_sequoiaTheme(background = "transparent", map = TRUE)
```

![](map_data_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

``` r
# save plot
cp_plotSave(filename = here("results", "maps", "asthma.png"), preset = "lg", dpi = 500)
```

### Race and Asthma

``` r
subtitle <- expression(paste("Pearson's ", italic("r"), " = 0.900, ", italic("p"), " < 0.001"))

ggplot(data = tracts, mapping = aes(x = ASTHMA, y = BLACK)) + 
  geom_point(position = "jitter", shape = 21, fill = "#349E8B", size = 4) + 
  geom_smooth(method = lm, color = "#E16033", size = 2) +
  labs(
    title = "Race and Asthma per Census Tract",
    subtitle = subtitle,
    x = "Proportion of Individuals with Current Asthma",
    y = "Proportion African Americans"
  ) +
  cp_sequoiaTheme(background = "gray")
```

![](map_data_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

``` r
# save plot
cp_plotSave(filename = here("results", "figures", "raceAsthma.png"), preset = "lg", dpi = 500)
```
