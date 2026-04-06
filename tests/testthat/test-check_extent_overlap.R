test_that("check_extent_overlap returns TRUE when bbox is inside layer extent", {
  result <- check_extent_overlap(c(-122, 37, -121, 38), "WRI_score")

  expect_true(isTRUE(result))
  expect_null(attr(result, "message"))
})

test_that("check_extent_overlap returns FALSE with a message for partial overlap", {
  result <- check_extent_overlap(c(-150, 37, -121, 38), "WRI_score")

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "extends outside layer 'WRI_score' extent")
  expect_match(attr(result, "message"), "left")
})

test_that("check_extent_overlap returns FALSE with a message for no overlap", {
  result <- check_extent_overlap(c(-180, -80, -170, -70), "WRI_score")

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "does not overlap")
})

test_that("check_extent_overlap returns FALSE with a message for invalid bbox", {
  result <- check_extent_overlap(c(-122, 37, -121), "WRI_score")

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "Invalid bounding box")
})

test_that("check_extent_overlap returns FALSE with a message for missing layer", {
  result <- check_extent_overlap(c(-122, 37, -121, 38), "not_a_real_layer")

  expect_false(isTRUE(result))
  expect_match(attr(result, "message"), "not found in the STAC catalog")
})
