# Input validation -------------------------------------------------------------

# Caching is reserved but not implemented yet.
test_that("wri_overview rejects fresh = FALSE", {
  expect_error(
    wri_overview(fresh = FALSE),
    "`fresh = FALSE` is not implemented yet. The catalog is always rebuilt from disk.",
    fixed = TRUE
  )
})

# Result shape -----------------------------------------------------------------

# wri_overview() should return its custom summary object.
test_that("wri_overview returns a wri_overview object", {
  result <- wri_overview()
  expect_s3_class(result, "wri_overview")
})

# The overview object should expose the catalog path, timestamp, and data.
test_that("wri_overview returns expected fields", {
  result <- wri_overview()
  expect_named(result, c("path", "built_at", "data", "wri_df"))
})

# built_at should be a usable timestamp, not a character string.
test_that("wri_overview built_at is a valid POSIXct timestamp", {
  result <- wri_overview()
  expect_s3_class(result$built_at, "POSIXct")
})

# The flattened catalog should be available on the overview object.
test_that("wri_overview wri_df is a data frame", {
  result <- wri_overview()
  expect_s3_class(result$wri_df, "data.frame")
})

# The data-frame helper should preserve columns used by downstream functions.
test_that("wri_overview_df returns required layer columns", {
  result <- wri_overview_df()

  expect_s3_class(result, "data.frame")
  expect_true(all(c("id", "asset_href", "xmin", "ymin", "xmax", "ymax") %in% names(result)))
})

# The bundled STAC catalog should discover at least one layer.
test_that("wri_overview wri_df has rows", {
  result <- wri_overview()
  expect_gt(nrow(result$wri_df), 0)
})

# Catalog path -----------------------------------------------------------------

# The resolved root catalog path should point to an existing file.
test_that("wri_overview path points to an existing file", {
  result <- wri_overview()
  expect_true(file.exists(result$path))
})
