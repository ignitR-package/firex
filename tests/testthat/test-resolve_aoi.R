# Check the output
test_that("resolve_aoi returns a SpatVector from numeric bbox", {
  result <- resolve_aoi(c(-122, 37, -121, 38), crs = "EPSG:4326")
  expect_true(isTRUE(result))
  expect_s4_class(attr(result, "polygon"), "SpatVector")
})

# Check if polygon has a valid CRS attached
test_that("resolve_aoi polygon has a CRS", {
  result <- resolve_aoi(c(-122, 37, -121, 38), crs = "EPSG:4326")
  expect_true(nzchar(terra::crs(attr(result, "polygon"))))
})

# Check if aoi is spatially valid
test_that("resolve_aoi polygon has non-zero extent", {
  result <- resolve_aoi(c(-122, 37, -121, 38), crs = "EPSG:4326")
  ext <- terra::ext(attr(result, "polygon"))
  expect_gt(ext$xmax - ext$xmin, 0)
  expect_gt(ext$ymax - ext$ymin, 0)
})

# Check unsupported aoi types
test_that("resolve_aoi fails safely on unsupported input", {
  result <- resolve_aoi(list(x = 1, y = 2), crs = NULL)
  expect_false(isTRUE(result))
  expect_type(attr(result, "message"), "character")
})
