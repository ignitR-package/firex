
# A STAC item with no properties should return NA, not crash
test_that(".wri_prop1 returns NA when properties is NULL", {
  expect_equal(firex:::.wri_prop1(list(properties = NULL), "key"), NA_character_)
})

# Missing hrefs in STAC links should return NA, not an empty string or error
test_that("wri_resolve_href returns NA for NULL href", {
  expect_equal(firex:::wri_resolve_href("/base/file.json", NULL), NA_character_)
})

# Empty string hrefs are treated the same as missing hrefs
test_that("wri_resolve_href returns NA for empty href", {
  expect_equal(firex:::wri_resolve_href("/base/file.json", ""), NA_character_)
})

# Absolute paths should be returned as is without joining to the base directory
test_that("wri_resolve_href handles absolute path", {
  result <- firex:::wri_resolve_href("/base/file.json", "/absolute/path.json")
  expect_true(grepl("absolute/path.json", result))
})

# A collection with no links should return an empty list, not error
test_that("wri_links_by_rel returns empty list for empty links", {
  expect_length(firex:::wri_links_by_rel(list(links = list()), "child"), 0)
})

# A STAC object with no links field should return an empty list, not error
test_that("wri_links_by_rel returns empty list for NULL links", {
  expect_length(firex:::wri_links_by_rel(list(links = NULL), "child"), 0)
})

# A STAC item with no assets should return an empty data frame, not error
test_that("wri_item_assets_df returns empty data frame for NULL assets", {
  result <- firex:::wri_item_assets_df(list(assets = NULL), "/item.json")
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

# An empty data frame input should pass through without error
test_that(".wri_pick_raster_asset returns input for empty df", {
  df <- data.frame(asset_type = character(), stringsAsFactors = FALSE)
  expect_equal(nrow(firex:::.wri_pick_raster_asset(df)), 0)
})

# A layer with only non-raster assets should return no rows
test_that(".wri_pick_raster_asset returns empty df when no geotiff found", {
  df <- data.frame(
    asset_type = "image/png",
    is_hosted  = "true",
    stringsAsFactors = FALSE
  )
  expect_equal(nrow(firex:::.wri_pick_raster_asset(df)), 0)
})

# An empty items list should return an empty data frame, not error
test_that("wri_items_df returns empty data frame for empty items", {
  result <- firex:::wri_items_df(list(items = list()))
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})
