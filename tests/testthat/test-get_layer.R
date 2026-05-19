# Fast preflight validation ----------------------------------------------------

# Invalid layer ids should fail before catalog or raster work.
test_that("get_layer validates id before retrieval", {
  expect_error(get_layer(), "`id` must be a single non-empty character string.")
})

# Invalid AOIs should fail before any remote raster request.
test_that("get_layer validates AOI before retrieval", {
  expect_error(
    get_layer(id = "WRI_score", aoi = c(-122, 37, -121)),
    "`aoi` has no CRS. Supply `aoi_crs` or attach a CRS to `aoi`.",
    fixed = TRUE
  )

  expect_error(
    get_layer(id = "WRI_score", aoi = c(-122, 37, -121), aoi_crs = "EPSG:4326"),
    "`aoi` must contain four numeric values: c(xmin, ymin, xmax, ymax).",
    fixed = TRUE
  )
})

# AOIs outside the STAC bbox should stop before opening the COG.
test_that("get_layer rejects AOIs outside the layer extent before retrieval", {
  expect_error(
    get_layer("WRI_score", aoi = c(-80, -90, -60, -70), aoi_crs = "EPSG:4326"),
    "does not overlap",
    fixed = TRUE
  )
})

# Supplying a second CRS for an object that already has one is ambiguous.
test_that("get_layer rejects CRS conflicts before retrieval", {
  vector <- terra::vect(terra::ext(-122, -121, 37, 38), crs = "EPSG:4326")

  expect_error(
    get_layer("WRI_score", aoi = vector, aoi_crs = "EPSG:4326"),
    "already has a CRS",
    fixed = TRUE
  )
})

# A valid AOI should allow the function to continue as far as layer lookup.
test_that("get_layer reaches layer lookup after valid AOI validation", {
  expect_error(
    get_layer("not_a_real_layer", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326"),
    "Layer not found",
    fixed = TRUE
  )
})

# Remote integration tests -----------------------------------------------------

# Remote COG tests are opt-in because they depend on network/GDAL availability.
test_that("get_layer returns a SpatRaster for a numeric bbox", {
  skip_if_not(Sys.getenv("FIREX_RUN_REMOTE_TESTS") == "true")

  result <- get_layer("WRI_score", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")

  expect_s4_class(result, "SpatRaster")
})

# Retrieved rasters should contain cells.
test_that("get_layer raster has cells", {
  skip_if_not(Sys.getenv("FIREX_RUN_REMOTE_TESTS") == "true")

  result <- get_layer("WRI_score", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")

  expect_gt(terra::ncell(result), 0)
})

# A raster AOI should follow the same crop path as vector/bbox AOIs.
test_that("get_layer accepts a SpatRaster as AOI", {
  skip_if_not(Sys.getenv("FIREX_RUN_REMOTE_TESTS") == "true")

  template <- terra::rast(terra::ext(-122, -121, 37, 38), crs = "EPSG:4326")
  result <- get_layer("WRI_score", aoi = template)

  expect_s4_class(result, "SpatRaster")
  expect_gt(terra::ncell(result), 0)
})

# WRI rasters are expected to be served in the package's projected CRS.
test_that("get_layer returns raster with expected CRS", {
  skip_if_not(Sys.getenv("FIREX_RUN_REMOTE_TESTS") == "true")

  result <- get_layer("WRI_score", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")

  expect_true(grepl("5070", terra::crs(result, describe = TRUE)$code))
})

# Current WRI layer assets should read as single-band rasters.
test_that("get_layer returns a single-layer raster", {
  skip_if_not(Sys.getenv("FIREX_RUN_REMOTE_TESTS") == "true")

  result <- get_layer("WRI_score", aoi = c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")

  expect_equal(terra::nlyr(result), 1)
})
