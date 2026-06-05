# STAC property helpers --------------------------------------------------------

test_that(".wri_prop1 returns first property value or NA", {
  expect_equal(.wri_prop1(list(properties = NULL), "missing"), NA_character_)
  expect_equal(.wri_prop1(list(properties = list()), "missing"), NA_character_)
  expect_equal(
    .wri_prop1(list(properties = list(domain = c("water", "air"))), "domain"),
    "water"
  )
})

# Href and link helpers --------------------------------------------------------

test_that("wri_resolve_href handles missing, URL, and relative hrefs", {
  base_file <- file.path(tempdir(), "catalog.json")

  expect_equal(wri_resolve_href(base_file, NULL), NA_character_)
  expect_equal(wri_resolve_href(base_file, ""), NA_character_)
  expect_equal(
    wri_resolve_href(base_file, "https://example.com/item.json"),
    "https://example.com/item.json"
  )
  expect_equal(
    wri_resolve_href(base_file, "/absolute/item.json"),
    normalizePath("/absolute/item.json", winslash = "/", mustWork = FALSE)
  )
  expect_equal(
    wri_resolve_href(base_file, "items/item.json"),
    normalizePath(
      file.path(tempdir(), "items", "item.json"),
      winslash = "/",
      mustWork = FALSE
    )
  )
})

test_that("wri_links_by_rel filters matching links", {
  empty <- wri_links_by_rel(list(), "item")
  expect_equal(empty, list())

  links <- list(
    list(rel = "child", href = "collection.json"),
    list(rel = "item", href = "item.json")
  )

  result <- wri_links_by_rel(list(links = links), "item")

  expect_length(result, 1)
  expect_equal(result[[1]]$href, "item.json")
})

# Asset and item flattening ----------------------------------------------------

test_that("wri_items_df returns an empty data frame for empty item lists", {
  expect_equal(wri_items_df(list(items = list())), data.frame())
})

test_that("wri_item_assets_df handles empty and populated assets", {
  empty <- wri_item_assets_df(list(), "item.json")

  expect_s3_class(empty, "data.frame")
  expect_equal(nrow(empty), 0)
  expect_named(empty, c("asset_name", "href", "type", "roles"))

  item <- list(
    assets = list(
      cog = list(
        href = "rasters/layer.tif",
        type = "image/tiff; application=geotiff",
        roles = c("data")
      ),
      metadata = list(href = "metadata.json")
    )
  )

  result <- wri_item_assets_df(item, file.path(tempdir(), "item.json"))

  expect_equal(result$asset_name, c("cog", "metadata"))
  expect_match(result$href[1], "rasters/layer.tif", fixed = TRUE)
  expect_equal(result$type[1], "image/tiff; application=geotiff")
  expect_equal(result$type[2], NA_character_)
  expect_equal(result$roles[[1]], "data")
  expect_equal(result$roles[[2]], character())
})

test_that("wri_items_df handles layers without assets", {
  empty_assets <- data.frame(
    asset_name = character(),
    href = character(),
    type = character(),
    roles = I(list()),
    stringsAsFactors = FALSE
  )

  data <- list(
    items = list(
      layer = list(
        id = "layer",
        collection = "wri",
        item_path = "items/layer.json",
        item = list(
          bbox = c(-1, -2, 3, 4),
          properties = list(
            datetime = "2026-01-01",
            `proj:code` = "EPSG:5070",
            data_type = "status",
            wri_domain = "water",
            wri_dimension = "status",
            is_hosted = TRUE
          )
        ),
        assets = empty_assets
      )
    )
  )

  result <- wri_items_df(data)

  expect_equal(nrow(result), 1)
  expect_equal(result$id, "layer")
  expect_equal(result$asset_href, NA_character_)
  expect_equal(result$xmin, -1)
  expect_equal(result$ymax, 4)
  expect_equal(result$wri_domain, "water")
})

test_that(".wri_pick_raster_asset prefers hosted GeoTIFF rows", {
  rows <- rbind(
    fake_layer_row(id = "layer", is_hosted = "FALSE"),
    fake_layer_row(id = "layer", is_hosted = "TRUE")
  )

  result <- .wri_pick_raster_asset(rows)

  expect_equal(nrow(result), 1)
  expect_equal(result$is_hosted, "TRUE")

  no_rasters <- fake_layer_row(asset_type = "application/json")
  expect_equal(nrow(.wri_pick_raster_asset(no_rasters)), 0)
  expect_null(.wri_pick_raster_asset(NULL))
})

# .wri_prop1 — empty value in properties list returns NA
test_that(".wri_prop1 returns NA for empty value", {
  expect_equal(.wri_prop1(list(properties = list(wri_domain = list())), "wri_domain"), NA_character_)
})

# wri_links_by_rel — no matching rel returns empty list
test_that("wri_links_by_rel returns empty list for unmatched rel", {
  links <- list(links = list(list(rel = "child", href = "a.json")))
  expect_length(wri_links_by_rel(links, "item"), 0)
})

# wri_item_assets_df — asset with no href returns NA
test_that("wri_item_assets_df handles asset with no href", {
  item <- list(assets = list(
    cog = list(type = "image/tiff; application=geotiff", roles = list("data"))
  ))
  result <- wri_item_assets_df(item, "/item.json")
  expect_equal(result$href, NA_character_)
})

# wri_items_df — item with NULL bbox returns NA coordinates
test_that("wri_items_df handles item with NULL bbox", {
  data <- list(items = list(layer = list(
    id = "layer", collection = "wri", item_path = "items/layer.json",
    item = list(bbox = NULL, properties = list(wri_domain = "water")),
    assets = data.frame(asset_name = character(), href = character(),
                        type = character(), roles = I(list()),
                        stringsAsFactors = FALSE)
  )))
  result <- wri_items_df(data)
  expect_true(is.na(result$xmin))
  expect_true(is.na(result$ymax))
})

# .wri_pick_raster_asset — NULL input returns NULL
test_that(".wri_pick_raster_asset returns NULL for NULL input", {
  expect_null(.wri_pick_raster_asset(NULL))
})
