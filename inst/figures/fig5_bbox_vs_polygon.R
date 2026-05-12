library(firex)
library(terra)
library(sf)

shp <- system.file("demos/data/Eaton_Perimeter_20250121.shp", package = "firex")
eaton_sf <- sf::st_read(shp, quiet = TRUE)

# Retrieve WRI score using the polygon object.
# get_layer() uses the geometry extent for retrieval.
wri_eaton <- get_layer("WRI_score", aoi = eaton_sf)

# Convert polygon to terra and project it to the raster CRS for plotting.
eaton_vect <- terra::vect(eaton_sf)
eaton_vect <- terra::project(eaton_vect, terra::crs(wri_eaton))

# Get the polygon extent as a rectangle.
eaton_extent <- terra::as.polygons(terra::ext(eaton_vect), crs = terra::crs(wri_eaton))

pal <- hcl.colors(100, "YlOrRd", rev = TRUE)

png("inst/figures/fig5_spatial_aoi_extent.png", width = 1400, height = 650, res = 150)

par(mfrow = c(1, 2), mar = c(3, 3, 4, 1))

plot(eaton_vect, main = "Input polygon and derived extent")
plot(eaton_extent, add = TRUE, border = "black", lwd = 2, lty = 2)

plot(
  wri_eaton,
  main = "Raster retrieved from polygon extent",
  col = pal,
  zlim = c(0, 1),
  legend = FALSE
)
plot(eaton_vect, add = TRUE, border = "black", lwd = 2)

dev.off()