# this script was used to create the great migration plot saved in `results/figures/popDecline.png`

# tidyverse packages
library(ggplot2)

# other packages
library(here)
library(prener)

# create data frame
popPlot <- data.frame(
  year = c(1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2016),
  pop = c(575238, 687029, 772897, 821960, 816048, 856796, 750026, 622236, 452801, 396685,
           348189, 319294, 311404)
)

# plot data
popOverTime <- ggplot(data = popPlot, aes(x = year, y = pop)) +
  geom_line(color = "#349E8B", size = 2) +
  scale_x_continuous(breaks = c(1900, 1920, 1940, 1960, 1980, 2000, 2016)) +
  scale_y_continuous(breaks = c(300000, 400000, 500000, 600000, 700000, 800000, 900000), labels = c(300, 400, 500, 600, 700, 800, 900), limits = c(300000, 900000)) +
  labs(title = "St. Louis's Population, 1900-2016", x = "Year", y = "Population (thousands)") +
  cp_sequoiaTheme(background = "gray")

# save plot
cp_plotSave(filename = here("results", "figures", "popDecline.png"), popOverTime, preset = "lg", dpi = 500)

# clean workspace
rm(list = ls())
