library(firex)
library(terra)

sb_bbox <- c(-120.7, 34.4, -119.4, 35.1)

wri <- get_layer("WRI_score", aoi = sb_bbox, aoi_crs = "EPSG:4326")

png("inst/figures/fig4_wri_score_bbox.png", width = 1000, height = 800, res = 150)

plot(
  wri,
  main = "WRI Score - Santa Barbara County",
  col = hcl.colors(100, "YlOrRd", rev = TRUE),
  zlim = c(0, 1)
)

dev.off()
