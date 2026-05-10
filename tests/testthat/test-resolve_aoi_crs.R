# Numeric input

test_that("resolve_aoi_crs rejects numeric bbox without CRS", {
  result <- resolve_aoi_crs(c(-122, 37, -121, 38), crs = NULL)
  expect_false(isTRUE(result))
  expect_type(attr(result, "message"), "character")
})

test_that("resolve_aoi_crs reorders numeric bbox to terra order", {
  # Global order: c(xmin, ymin, xmax, ymax)
  # Terra order: c(xmin, xmax, ymin, ymax)
  result <- resolve_aoi_crs(c(-122, 37, -121, 38), crs = "EPSG:4326")
  expect_true(isTRUE(result))
  expect_equal(attr(result, "bbox"), c(-122, -121, 37, 38))
})


# CRS normalization

test_that("resolve_aoi_crs accepts integer EPSG code", {
  result <- resolve_aoi_crs(c(-122, 37, -121, 38), crs = 4326)
  expect_true(isTRUE(result))
  expect_equal(attr(result, "crs"), "EPSG:4326")
})

test_that("resolve_aoi_crs rejects unrecognized CRS", {
  result <- resolve_aoi_crs(c(-122, 37, -121, 38), crs = "EPSG:12345")
  expect_false(isTRUE(result))
  expect_type(attr(result, "message"), "character")
})

# Spatial object with CRS

test_that("resolve_aoi_crs attaches CRS to CRS-less SpatVector", {
  v <- terra::vect(terra::ext(-122, -121, 37, 38))  # no CRS
  result <- resolve_aoi_crs(v, crs = "EPSG:4326")
  expect_true(isTRUE(result))
  expect_true(nzchar(attr(result, "crs")))
})

test_that("resolve_aoi_crs detects CRS conflict", {
  v <- terra::vect(terra::ext(-122, -121, 37, 38), crs = "EPSG:4326")
  result <- resolve_aoi_crs(v, crs = "EPSG:32610")  # conflict
  expect_false(isTRUE(result))
  expect_type(attr(result, "message"), "character")
})
