# Test input

test_that("wri_overview rejects fresh = FALSE", {
  expect_error(
    wri_overview(fresh = FALSE),
    "`fresh = FALSE` is not implemented yet. The catalog is always rebuilt from disk.",
    fixed = TRUE
  )
})

# Test result

test_that("wri_overview returns a wri_overview object", {
  result <- wri_overview()
  expect_s3_class(result, "wri_overview")
})

test_that("wri_overview returns expected fields", {
  result <- wri_overview()
  expect_named(result, c("path", "built_at", "data", "wri_df"))
})

test_that("wri_overview built_at is a valid POSIXct timestamp", {
  result <- wri_overview()
  expect_s3_class(result$built_at, "POSIXct")
})

test_that("wri_overview wri_df is a data frame", {
  result <- wri_overview()
  expect_s3_class(result$wri_df, "data.frame")
})

test_that("wri_overview_df returns required layer columns", {
  result <- wri_overview_df()

  expect_s3_class(result, "data.frame")
  expect_true(all(c("id", "asset_href", "xmin", "ymin", "xmax", "ymax") %in% names(result)))
})

test_that("wri_overview wri_df has rows", {
  result <- wri_overview()
  expect_gt(nrow(result$wri_df), 0)
})

# Test edge case of missing file path

test_that("wri_overview path points to an existing file", {
  result <- wri_overview()
  expect_true(file.exists(result$path))
})
