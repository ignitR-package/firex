# Input validation -------------------------------------------------------------

# Missing ids should fail before reading catalog rows.
test_that("layer_info rejects missing layer_id", {
  expect_error(
    layer_info(),
    "`layer_id` must be a single non-empty character string.",
    fixed = TRUE
  )
})

# Layer ids must be character scalars.
test_that("layer_info rejects non-character layer_id", {
  expect_error(
    layer_info(123),
    "`layer_id` must be a single non-empty character string.",
    fixed = TRUE
  )
})

# Empty strings are not valid layer ids.
test_that("layer_info rejects empty string", {
  expect_error(
    layer_info(""),
    "`layer_id` must be a single non-empty character string.",
    fixed = TRUE
  )
})

# Caching is reserved but not implemented yet.
test_that("layer_info rejects fresh = FALSE", {
  expect_error(
    layer_info("WRI_score", fresh = FALSE),
    "`fresh = FALSE` is not implemented yet. The catalog is always rebuilt from disk.",
    fixed = TRUE
  )
})

# Unknown ids should produce a helpful catalog error.
test_that("layer_info rejects unknown layer_id", {
  expect_error(
    layer_info("not_a_real_layer"),
    "Layer not found: `not_a_real_layer`.",
    fixed = TRUE
  )
})

# Result shape -----------------------------------------------------------------

# A successful lookup returns tabular metadata.
test_that("layer_info returns a data frame", {
  result <- layer_info("WRI_score")
  expect_s3_class(result, "data.frame")
})

# Layer ids should be unique in the flattened catalog.
test_that("layer_info returns exactly one row", {
  result <- layer_info("WRI_score")
  expect_equal(nrow(result), 1)
})

# The returned row should be for the requested layer.
test_that("layer_info returns correct layer id", {
  result <- layer_info("WRI_score")
  expect_equal(result$id, "WRI_score")
})

# Layer extent metadata is required for AOI overlap checks.
test_that("layer_info returns finite layer bbox fields", {
  result <- layer_info("WRI_score")
  bbox <- as.numeric(result[1, c("xmin", "ymin", "xmax", "ymax")])

  expect_true(all(is.finite(bbox)))
})
