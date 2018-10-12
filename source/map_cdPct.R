# this script was used to create the map of % redlined by tract saved in `results/maps/cdPct.png`
# it is called by `docs/redlining_area.Rmd` and is not written to be stand alon

## define jenks for percent redlined
cdJenks <- cp_breaks(redAreas, var = cdPct, newvar = cdJenks, classes = 5, style = "jenks")

# map redlined areas
ggplot() +
  geom_sf(data = cdJenks, mapping = aes(fill = cdJenks), color = "#A6AAA9") +
  geom_sf(data = city_hwys, mapping = aes(color = "Highways"), size = 1.5, fill = NA) +
  geom_sf(data = city, fill = NA, color = "#000000", size = .25) +
  scale_fill_brewer(palette = "Reds", name = "Percent",
                    labels = c("< 8.6", "8.6 - 35.5", "35.5 - 59.2", "59.2 - 86.3", "> 86.3")) +
  scale_colour_manual(name="", values= "black") +
  labs(
    title = " ",
    subtitle = "Percent Graded \"C\" or \"D\""
  ) +
  cp_sequoiaTheme(background = "transparent", map = TRUE)

# save plot
cp_plotSave(filename = here("results", "maps", "cdPct.png"), preset = "lg", dpi = 500)

# clean workspace
rm(cdJenks)
