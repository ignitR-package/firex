# Null AOIs --------------------------------------------------------------------

# NULL means "no crop" and should return empty AOI metadata.
test_that("resolve_aoi returns NULL metadata for NULL AOI", {
  result <- resolve_aoi(NULL)

  expect_true(isTRUE(result))
  expect_null(attr(result, "aoi"))
  expect_null(attr(result, "bbox"))
  expect_null(attr(result, "extent"))
  expect_null(attr(result, "crs"))
})

# Numeric bbox handling --------------------------------------------------------

# Public bbox attributes stay in user order: xmin, ymin, xmax, ymax.
test_that("resolve_aoi returns bbox in user order", {
  result <- resolve_aoi(c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")

  expect_true(isTRUE(result))
  expect_equal(attr(result, "bbox"), c(xmin = -122, ymin = 37, xmax = -121, ymax = 38))
})

# The terra extent gets the same numbers in terra's xmin/xmax/ymin/ymax slots.
test_that("resolve_aoi reorders numeric bbox for terra extent creation", {
  result <- resolve_aoi(c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")
  extent <- attr(result, "extent")

  expect_true(isTRUE(result))
  expect_equal(as.numeric(extent$xmin), -122)
  expect_equal(as.numeric(extent$xmax), -121)
  expect_equal(as.numeric(extent$ymin), 37)
  expect_equal(as.numeric(extent$ymax), 38)
})

# Successful AOI resolution should return all metadata get_layer() needs.
test_that("resolve_aoi returns polygon, extent, CRS, and type metadata", {
  result <- resolve_aoi(c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")

  expect_true(isTRUE(result))
  expect_s4_class(attr(result, "aoi"), "SpatVector")
  expect_s4_class(attr(result, "extent"), "SpatExtent")
  expect_true(terra::same.crs(attr(result, "crs"), "EPSG:4326"))
  expect_equal(attr(result, "type"), "bbox")
})

# Malformed numeric bboxes should fail before polygon construction.
test_that("resolve_aoi rejects invalid numeric bboxes", {
  short <- resolve_aoi(c(-122, 37, -121), aoi_crs = "EPSG:4326")
  reversed_x <- resolve_aoi(c(-121, 37, -122, 38), aoi_crs = "EPSG:4326")
  reversed_y <- resolve_aoi(c(-122, 38, -121, 37), aoi_crs = "EPSG:4326")
  zero_area <- resolve_aoi(c(-122, 37, -122, 38), aoi_crs = "EPSG:4326")

  expect_false(isTRUE(short))
  expect_false(isTRUE(reversed_x))
  expect_false(isTRUE(reversed_y))
  expect_false(isTRUE(zero_area))
  expect_match(attr(short, "message"), "four numeric values")
  expect_match(attr(reversed_x, "message"), "xmin")
  expect_match(attr(reversed_y, "message"), "ymin")
  expect_match(attr(zero_area, "message"), "xmin")
})

# File and terra object inputs -------------------------------------------------

# Common vector file paths should be read and resolved through terra::vect().
test_that("resolve_aoi accepts shapefile and GeoJSON paths", {

  shp <- system.file(
    "demos/data/Eaton_Perimeter_20250121.shp",
    package = "firex",
    mustWork = TRUE
  )

  geojson <- system.file(
    "demos/data/Eaton_Fire_Perimeter.geojson",
    package = "firex",
    mustWork = TRUE
  )

  shp_result <- resolve_aoi(shp)
  geojson_result <- resolve_aoi(geojson)

  expect_true(isTRUE(shp_result))
  expect_true(isTRUE(geojson_result))
  expect_equal(attr(shp_result, "type"), "SpatVector")
  expect_equal(attr(geojson_result, "type"), "SpatVector")
  expect_named(attr(shp_result, "bbox"), c("xmin", "ymin", "xmax", "ymax"))
  expect_named(attr(geojson_result, "bbox"), c("xmin", "ymin", "xmax", "ymax"))
  expect_true(nzchar(attr(shp_result, "crs")))
  expect_true(nzchar(attr(geojson_result, "crs")))
})

# Existing files that are not spatial data should return a structured error.
test_that("resolve_aoi rejects unreadable spatial file paths", {
  path <- tempfile(fileext = ".txt")
  writeLines("not spatial data", path)

  result <- suppressWarnings(resolve_aoi(path))

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "could not be read")
})

# Already-loaded terra objects should be accepted without file-path handling.
test_that("resolve_aoi accepts terra vector, raster, and extent inputs", {
  vector <- terra::vect(terra::ext(-122, -121, 37, 38), crs = "EPSG:4326")
  raster <- terra::rast(terra::ext(-122, -121, 37, 38), crs = "EPSG:4326")
  extent <- terra::ext(-122, -121, 37, 38)

  vector_result <- resolve_aoi(vector)
  raster_result <- resolve_aoi(raster)
  extent_result <- resolve_aoi(extent, aoi_crs = "EPSG:4326")

  expect_true(isTRUE(vector_result))
  expect_true(isTRUE(raster_result))
  expect_true(isTRUE(extent_result))
  expect_equal(attr(vector_result, "type"), "SpatVector")
  expect_equal(attr(raster_result, "type"), "SpatRaster")
  expect_equal(attr(extent_result, "type"), "SpatExtent")
})

# Unsupported inputs should return a structured failure, not throw.
test_that("resolve_aoi fails safely on unsupported input", {
  result <- resolve_aoi(list(x = 1, y = 2), aoi_crs = "EPSG:4326")

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "not in a supported format")
})
