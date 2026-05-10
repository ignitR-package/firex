
# Check the return type
test_that("get_layer returns a SpatRaster for a numeric bbox", {
  skip_if_offline()
  result <- get_layer("WRI_score", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")
  expect_s4_class(result, "SpatRaster")
})

# Check if the raster is not empty
test_that("get_layer raster has cells", {
  skip_if_offline()
  result <- get_layer("WRI_score", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")
  expect_gt(terra::ncell(result), 0)
})

# Test with SpatRast input

test_that("get_layer accepts a SpatRaster as aoi", {
  skip_if_offline()
  template <- terra::rast(terra::ext(-122, -121, 37, 38), crs = "EPSG:4326")
  result <- get_layer("WRI_score", aoi = template)
  expect_s4_class(result, "SpatRaster")
  expect_gt(terra::ncell(result), 0)
})

# Check if returns raster in a consistent CRS

test_that("get_layer returns raster with correct CRS", {
  skip_if_offline()
  result <- get_layer("WRI_score", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")
  expect_true(grepl("5070", terra::crs(result, describe = TRUE)$code))
})

# Check if returns a single layer raster

test_that("get_layer returns single layer raster", {
  skip_if_offline()
  result <- get_layer("WRI_score", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")
  expect_equal(terra::nlyr(result), 1)
})
