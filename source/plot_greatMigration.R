# this script was used to create the great migration plot saved in `results/figures/greatMigration.png`

# tidyverse packages
library(dplyr)
library(ggplot2)

# other packages
library(here)
library(prener)

# create data frame
greatMigration <- data.frame(
  year = c(1900, 1910, 1920, 1930, 1940, 1940, 1950, 1960, 1970),
  era = c("first", "first", "first", "first", "first", "second", "second", "second", "second"),
  pct_black = c(6.2, 6.4, 9.0, 11.4, 13.3, 13.13, 17.9, 28.6, 40.9)
)

# plot data
plot <- ggplot(data = greatMigration) +
  geom_line(mapping = aes(x = year, y = pct_black, group = era, color = era), size = 2) +
  scale_x_continuous(breaks = c(1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970)) +
  scale_color_manual(values=c("#349E8B", "#E16033"), guide = guide_legend(title = "Wave")) +
  labs(
    title = "The Great Migration in St. Louis City",
    subtitle = "African American Population Growth, 1900-1970",
    x = "Year",
    y = "% African American"
  ) +
  cp_sequoiaTheme(background = "gray")

# save plot
cp_plotSave(filename = here("results", "figures", "greatMigration.png"), plot, preset = "lg", dpi = 500)
