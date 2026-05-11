test_that("query_stac_flexible filters items by property", {
  items <- list(
    list(id = "a", properties = list(wri_domain = "water", data_type = "status")),
    list(id = "b", properties = list(wri_domain = "land", data_type = "status")),
    list(id = "c", properties = list(wri_domain = "water", data_type = "trend"))
  )

  matches <- query_stac_flexible(items, wri_domain = "water", data_type = "status")

  expect_type(matches, "list")
  expect_length(matches, 1)
  expect_identical(matches[[1]]$id, "a")
})

test_that("layer_info validates inputs before reading the catalog", {
  expect_error(layer_info(), "`layer_id` must be a single non-empty character string.")
  expect_error(
    layer_info("WRI_score", fresh = FALSE),
    fixed = TRUE,
    "`fresh = FALSE` is not implemented yet."
  )
})

test_that("get_layer validates inputs before attempting retrieval", {
  expect_error(get_layer(), "`id` must be a single non-empty character string.")
  expect_error(
    get_layer(id = "WRI_score", aoi = c(-122, 37, -121)),
    fixed = TRUE,
    "`aoi` has no CRS. Supply `aoi_crs` or attach a CRS to `aoi`."
  )
  expect_error(
    get_layer(id = "WRI_score", aoi = c(-122, 37, -121), aoi_crs = "EPSG:4326"),
    fixed = TRUE,
    "`aoi` could not be converted to a terra-compatible spatial object."
  )
})
