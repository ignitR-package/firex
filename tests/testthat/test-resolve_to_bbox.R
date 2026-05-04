test_that("resolve_to_bbox accepts matching normalized aoi_crs for objects that already have a CRS", {
  aoi <- terra::as.polygons(terra::ext(0, 1, 0, 1), crs = "EPSG:4326")

  result <- resolve_to_bbox(aoi, aoi_crs = "EPSG:4326")

  expect_true(isTRUE(result))
  expect_equal(unname(attr(result, "bbox")), c(0, 0, 1, 1))
  expect_true(terra::same.crs(attr(result, "crs"), "EPSG:4326"))
})

test_that("resolve_to_bbox rejects conflicting normalized aoi_crs for objects that already have a CRS", {
  aoi <- terra::as.polygons(terra::ext(0, 1, 0, 1), crs = "EPSG:4326")

  result <- resolve_to_bbox(aoi, aoi_crs = "EPSG:5070")

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "does not match")
})
