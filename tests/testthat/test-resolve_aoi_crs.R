# Numeric bbox CRS requirements ------------------------------------------------

# Numeric bboxes carry no CRS, so callers must supply one.
test_that("resolve_aoi_crs rejects numeric bbox without CRS", {
  result <- resolve_aoi_crs(c(-122, 37, -121, 38), aoi_crs = NULL)

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "has no CRS")
})

# Character CRS values should pass through when terra recognizes them.
test_that("resolve_aoi_crs accepts numeric bbox with character CRS", {
  result <- resolve_aoi_crs(c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")

  expect_true(isTRUE(result))
  expect_equal(attr(result, "crs"), "EPSG:4326")
})

# EPSG values can be supplied as either integers or digit strings.
test_that("resolve_aoi_crs normalizes numeric and digit-string EPSG codes", {
  result_integer <- resolve_aoi_crs(c(-122, 37, -121, 38), aoi_crs = 4326)
  result_string <- resolve_aoi_crs(c(-122, 37, -121, 38), aoi_crs = "4326")

  expect_true(isTRUE(result_integer))
  expect_true(isTRUE(result_string))
  expect_equal(attr(result_integer, "crs"), "EPSG:4326")
  expect_equal(attr(result_string, "crs"), "EPSG:4326")
})

# Bad CRS strings should fail before any AOI geometry work.
test_that("resolve_aoi_crs rejects unrecognized CRS", {
  result <- resolve_aoi_crs(c(-122, 37, -121, 38), aoi_crs = "not-a-crs")

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "not recognized")
})

# Attached CRS handling --------------------------------------------------------

# Spatial objects with an attached CRS should supply that CRS directly.
test_that("resolve_aoi_crs returns attached object CRS", {
  v <- terra::vect(terra::ext(-122, -121, 37, 38), crs = "EPSG:4326")

  result <- resolve_aoi_crs(v)

  expect_true(isTRUE(result))
  expect_true(terra::same.crs(attr(result, "crs"), "EPSG:4326"))
})

# A user-provided CRS conflicts with an object that already has one.
test_that("resolve_aoi_crs rejects CRS conflicts", {
  v <- terra::vect(terra::ext(-122, -121, 37, 38), crs = "EPSG:4326")

  result <- resolve_aoi_crs(v, aoi_crs = "EPSG:32610")

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "already has a CRS")
})

# SpatExtent objects are CRS-less and need an explicit aoi_crs.
test_that("resolve_aoi_crs handles CRS-less SpatExtent", {
  extent <- terra::ext(-122, -121, 37, 38)

  missing <- resolve_aoi_crs(extent)
  supplied <- resolve_aoi_crs(extent, aoi_crs = "EPSG:4326")

  expect_false(isTRUE(missing))
  expect_match(attr(missing, "message"), "has no CRS")
  expect_true(isTRUE(supplied))
  expect_equal(attr(supplied, "crs"), "EPSG:4326")
})
