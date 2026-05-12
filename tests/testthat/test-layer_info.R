# test inputs

test_that("layer_info rejects missing layer_id", {
  expect_error(
    layer_info(),
    "`layer_id` must be a single non-empty character string.",
    fixed = TRUE
  )
})

test_that("layer_info rejects non-character layer_id", {
  expect_error(
    layer_info(123),
    "`layer_id` must be a single non-empty character string.",
    fixed = TRUE
  )
})

test_that("layer_info rejects empty string", {
  expect_error(
    layer_info(""),
    "`layer_id` must be a single non-empty character string.",
    fixed = TRUE
  )
})

test_that("layer_info rejects fresh = FALSE", {
  expect_error(
    layer_info("WRI_score", fresh = FALSE),
    "`fresh = FALSE` is not implemented yet. The catalog is always rebuilt from disk.",
    fixed = TRUE
  )
})

test_that("layer_info rejects unknown layer_id", {
  expect_error(
    layer_info("not_a_real_layer"),
    "Layer not found: `not_a_real_layer`.",
    fixed = TRUE
  )
})

# Test results

test_that("layer_info returns a data frame", {
  result <- layer_info("WRI_score")
  expect_s3_class(result, "data.frame")
})

test_that("layer_info returns exactly one row", {
  result <- layer_info("WRI_score")
  expect_equal(nrow(result), 1)
})

test_that("layer_info returns correct layer id", {
  result <- layer_info("WRI_score")
  expect_equal(result$id, "WRI_score")
})

test_that("layer_info returns finite layer bbox fields", {
  result <- layer_info("WRI_score")
  bbox <- as.numeric(result[1, c("xmin", "ymin", "xmax", "ymax")])

  expect_true(all(is.finite(bbox)))
})
