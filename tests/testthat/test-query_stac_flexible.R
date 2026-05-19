# Property filtering -----------------------------------------------------------

# Multiple named filters should be combined with AND semantics.
test_that("query_stac_flexible filters items by property", {
  items <- list(
    list(id = "a", properties = list(wri_domain = "water", data_type = "status")),
    list(id = "b", properties = list(wri_domain = "land", data_type = "status")),
    list(id = "c", properties = list(wri_domain = "water", data_type = "trend"))
  )

  matches <- query_stac_flexible(items, wri_domain = "water", data_type = "status")

  expect_type(matches, "list")
  expect_length(matches, 1)
  expect_identical(matches[[1]]$id, "a")
})
