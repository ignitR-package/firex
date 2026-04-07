test_that("is_valid_bbox accepts valid bounding boxes", {
  result <- is_valid_bbox(c(-120, 30, -100, 50))
  expect_true(isTRUE(result))
  expect_equal(attr(result, "status"), "valid")
  expect_equal(attr(result, "bbox"), c(-120, 30, -100, 50))
  expect_true(is_valid_bbox(c(-180, -90, 180, 90)))  # Global bbox
  expect_true(is_valid_bbox(c(0, 0, 10, 10)))
})

test_that("is_valid_bbox rejects invalid coordinate ordering", {
  result_x <- is_valid_bbox(c(-100, 30, -120, 50))  # xmin > xmax
  expect_false(isTRUE(result_x))
  expect_match(attr(result_x, "message"), "You supplied bbox = c\\(xmin = -100, ymin = 30, xmax = -120, ymax = 50\\)")
  expect_match(attr(result_x, "message"), "`xmin` must be less than `xmax`")

  result_y <- is_valid_bbox(c(-120, 50, -100, 30))  # ymin > ymax
  expect_false(isTRUE(result_y))
  expect_match(attr(result_y, "message"), "You supplied bbox = c\\(xmin = -120, ymin = 50, xmax = -100, ymax = 30\\)")
  expect_match(attr(result_y, "message"), "`ymin` must be less than `ymax`")
})

test_that("is_valid_bbox rejects out-of-range coordinates", {
  result_lon <- is_valid_bbox(c(-200, 30, -100, 50))   # xmin too small
  expect_false(isTRUE(result_lon))
  expect_match(attr(result_lon, "message"), "`xmin` and `xmax` must be between -180 and 180")

  result_lat <- is_valid_bbox(c(-120, -100, -100, 50)) # ymin too small
  expect_false(isTRUE(result_lat))
  expect_match(attr(result_lat, "message"), "`ymin` and `ymax` must be between -90 and 90")
})

test_that("is_valid_bbox rejects wrong data types", {
  result_char <- is_valid_bbox(c("a", "b", "c", "d"))
  expect_false(isTRUE(result_char))
  expect_match(attr(result_char, "message"), "must contain four numeric values")

  result_list <- is_valid_bbox(list(-120, 30, -100, 50))
  expect_false(isTRUE(result_list))
  expect_match(attr(result_list, "message"), "must contain four numeric values")
})

test_that("is_valid_bbox rejects wrong length", {
  result_short <- is_valid_bbox(c(-120, 30, -100))       # length 3
  expect_false(isTRUE(result_short))
  expect_match(attr(result_short, "message"), "must contain four numeric values")

  result_long <- is_valid_bbox(c(-120, 30, -100, 50, 60)) # length 5
  expect_false(isTRUE(result_long))
  expect_match(attr(result_long, "message"), "must contain four numeric values")
})
