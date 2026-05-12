library(firex)
library(terra)

sb_bbox <- c(-120.7, 34.4, -119.4, 35.1)

# Use explicit IDs so the panel order is stable.
water_ids <- c(
  "water_domain_score",
  "water_resilience",
  "water_resistance",
  "water_status"
)

water_layers <- lapply(
  water_ids,
  function(id) get_layer(id, aoi = sb_bbox, aoi_crs = "EPSG:4326")
)

water_stack <- do.call(c, water_layers)

names(water_stack) <- c(
  "Domain score",
  "Resilience",
  "Resistance",
  "Status"
)

png("inst/figures/fig6_water_domains.png", width = 1600, height = 1200, res = 150)
plot(
  water_stack,
  col = hcl.colors(100, "YlOrRd", rev = TRUE),
  zlim = c(0, 1)
)
dev.off()
