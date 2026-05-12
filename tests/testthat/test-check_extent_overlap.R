test_that("check_extent_overlap returns inside for contained bboxes", {
  layer_bbox <- c(-146.2082, 19.1074, 173.7109, 54.8056)

  result <- check_extent_overlap(c(-122, 37, -121, 38), layer_bbox)

  expect_true(isTRUE(result))
  expect_equal(attr(result, "status"), "inside")
  expect_null(attr(result, "message"))
})

test_that("check_extent_overlap treats equal extents as inside", {
  layer_bbox <- c(-146.2082, 19.1074, 173.7109, 54.8056)

  result <- check_extent_overlap(layer_bbox, layer_bbox)

  expect_true(isTRUE(result))
  expect_equal(attr(result, "status"), "inside")
})

test_that("check_extent_overlap reports each partial-overlap side", {
  layer_bbox <- c(-146.2082, 19.1074, 173.7109, 54.8056)

  cases <- list(
    west = c(-150, 37, -121, 38),
    south = c(-122, 18, -121, 38),
    east = c(-122, 37, 174, 38),
    north = c(-122, 37, -121, 56)
  )

  for (side in names(cases)) {
    result <- check_extent_overlap(cases[[side]], layer_bbox)

    expect_false(isTRUE(result), info = side)
    expect_equal(attr(result, "status"), "partial", info = side)
    expect_match(attr(result, "message"), side, info = side)
  }
})

test_that("check_extent_overlap returns none when bbox does not overlap", {
  layer_bbox <- c(-146.2082, 19.1074, 173.7109, 54.8056)

  result <- check_extent_overlap(c(-180, -80, -170, -70), layer_bbox)

  expect_false(isTRUE(result))
  expect_equal(attr(result, "status"), "none")
  expect_match(attr(result, "message"), "does not overlap")
})

test_that("check_extent_overlap treats edge-touching outside bboxes as no overlap", {
  layer_bbox <- c(-146.2082, 19.1074, 173.7109, 54.8056)

  result <- check_extent_overlap(c(173.7109, 37, 174, 38), layer_bbox)

  expect_false(isTRUE(result))
  expect_equal(attr(result, "status"), "none")
})
