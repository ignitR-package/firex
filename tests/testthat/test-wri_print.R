
# The printed output should return x invisibly, following R's print method convention
test_that("print.wri_overview returns x invisibly", {
  x <- wri_overview()
  result <- withVisible(print(x))
  expect_false(result$visible)
  expect_identical(result$value, x)
})

# The printed output should return a data summary
test_that("print.wri_overview outputs WRI DATA SUMMARY header", {
  x <- wri_overview()
  output <- capture.output(print(x))
  expect_true(any(grepl("WRI DATA SUMMARY", output)))
})

# The printed output should return the time stamp
test_that("print.wri_overview outputs built_at timestamp", {
  x <- wri_overview()
  output <- capture.output(print(x))
  expect_true(any(grepl("Read at", output)))
})

# The printed output should include the collections section
test_that("print.wri_overview outputs collections count", {
  x <- wri_overview()
  output <- capture.output(print(x))
  expect_true(any(grepl("Collections", output)))
})

# The printed output should return the total layers available
test_that("print.wri_overview outputs total layers", {
  x <- wri_overview()
  output <- capture.output(print(x))
  expect_true(any(grepl("Total layers available", output)))
})

# The function handles missing values appropriate
test_that("print.wri_overview handles missing collections appropriately", {
  x <- wri_overview()
  x$data$collections <- NULL
  output <- capture.output(print(x))
  expect_true(any(grepl("Collections: 0", output)))
})

