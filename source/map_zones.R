# this script was used to create the map of % redlined by tract saved in `results/maps/zones.png`
# it is called by `docs/redlining_area.Rmd` and is not written to be stand alon

# map redlined areas
ggplot() +
  geom_sf(data = city, fill = "#f8f8f8", color = NA) +
  geom_sf(data = redClean, mapping = aes(fill = holc_grade), color = "#000000", size = .1) +
  geom_sf(data = city_hwys, color = "#000000", size = 1.5) +
  geom_sf(data = city, fill = NA , color = "#000000", size = .25) +
  scale_fill_manual(name = "Zones", values = c("#7BA977", "#7DA8BF", "#CFD173", "#DCA1AC")) +
  labs(
    title = "Redlined Areas of St. Louis",
    subtitle = "All Zones"
  ) +
  cp_sequoiaTheme(background = "transparent", map = TRUE)

# save plot
cp_plotSave(filename = here("results", "maps", "zones.png"), preset = "lg", dpi = 500)
