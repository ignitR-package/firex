test_that("is_valid_bbox accepts valid bounding boxes", {
  result <- is_valid_bbox(c(-120, 30, -100, 50))
  expect_true(isTRUE(result))
  expect_equal(attr(result, "status"), "valid")
  expect_equal(attr(result, "bbox"), c(-120, 30, -100, 50))
  expect_true(is_valid_bbox(c(-180, -90, 180, 90)))  # Global bbox
  expect_true(is_valid_bbox(c(0, 0, 10, 10)))
})

test_that("is_valid_bbox rejects invalid coordinate ordering", {
  expect_false(is_valid_bbox(c(-100, 30, -120, 50)))  # xmin > xmax
  expect_false(is_valid_bbox(c(-120, 50, -100, 30)))  # ymin > ymax
})

test_that("is_valid_bbox rejects out-of-range coordinates", {
  expect_false(is_valid_bbox(c(-200, 30, -100, 50)))   # xmin too small
  expect_false(is_valid_bbox(c(-120, 30, 200, 50)))    # xmax too large
  expect_false(is_valid_bbox(c(-120, -100, -100, 50))) # ymin too small
  expect_false(is_valid_bbox(c(-120, 30, -100, 100)))  # ymax too large
})

test_that("is_valid_bbox rejects wrong data types", {
  expect_false(is_valid_bbox(c("a", "b", "c", "d")))
  expect_false(is_valid_bbox(list(-120, 30, -100, 50)))
})

test_that("is_valid_bbox rejects wrong length", {
  expect_false(is_valid_bbox(c(-120, 30, -100)))       # length 3
  expect_false(is_valid_bbox(c(-120, 30, -100, 50, 60))) # length 5
})
