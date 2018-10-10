# this script was used to create the map of median income by tract saved in `results/plots/incomeRace.png`

# tidyverse packages
library(dplyr)
library(ggplot2)

# spatial packages
library(tidycensus)

# other packages
library(here)
library(prener)

# download income data
medianInc <- get_acs("tract", variable = "B19019_001", state = 29, county = 510)

# clean income data
medianInc %>%
  select(GEOID, estimate) %>%
  rename(medianInc = estimate) -> inc

# download race data
race <- get_acs("tract", table = "B02001", state = 29, county = 510, output = "wide")

# clean race data
race %>%
  select(GEOID, B02001_001E, B02001_003E) %>%
  mutate(pctBlack = (B02001_003E/B02001_001E)*100) %>%
  select(GEOID, pctBlack) -> pctBlack

# merge income and tract data
incomeRace <- left_join(pctBlack, inc, by = "GEOID")

ggplot(data = incomeRace, mapping = aes(x = pctBlack, y = medianInc)) +
  geom_point(shape = 21, fill = "#349E8B", size = 4) +
  geom_smooth(color = "#E16033", size = 2) +
  labs(
    title = "Income and Race per Census Tract",
    subtitle = "Overlaid with a LOESS model and confidence interval",
    x = "Percent African American",
    y = "Median Household Income"
  ) +
  cp_sequoiaTheme(background = "gray")

# save plot
cp_plotSave(filename = here("results", "figures", "incomeRace.png"), preset = "lg", dpi = 500)

# clean workspace
rm(list = ls())

