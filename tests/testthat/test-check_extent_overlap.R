test_that("check_extent_overlap returns TRUE when bbox is inside layer extent", {
  layer_bbox <- c(-146.2082, 19.1074, 173.7109, 54.8056)
  result <- check_extent_overlap(c(-122, 37, -121, 38), layer_bbox)

  expect_true(isTRUE(result))
  expect_equal(attr(result, "status"), "inside")
  expect_null(attr(result, "message"))
})

test_that("check_extent_overlap returns FALSE with a message for partial overlap", {
  layer_bbox <- c(-146.2082, 19.1074, 173.7109, 54.8056)
  result <- check_extent_overlap(c(-150, 37, -121, 38), layer_bbox)

  expect_false(isTRUE(result))
  expect_equal(attr(result, "status"), "partial")
  expect_match(attr(result, "message"), "extends outside the layer extent")
  expect_match(attr(result, "message"), "left")
})

test_that("check_extent_overlap returns FALSE with a message for no overlap", {
  layer_bbox <- c(-146.2082, 19.1074, 173.7109, 54.8056)
  result <- check_extent_overlap(c(-180, -80, -170, -70), layer_bbox)

  expect_false(isTRUE(result))
  expect_equal(attr(result, "status"), "none")
  expect_match(attr(result, "message"), "does not overlap")
})
