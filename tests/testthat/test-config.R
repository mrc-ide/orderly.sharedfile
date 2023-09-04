test_that("config must contain at least one folder", {
  expect_error(
    config(list(), "orderly.yml"),
    "orderly.yml:orderly.sharedfile must contain at least one folder")
})


test_that("config must contain unique folder names", {
  expect_error(
    config(list(a = "x", b = "y", a = "z"), "orderly.yml"),
    "'orderly.yml:orderly.sharedfile' must have unique names")
})


test_that("expand shorthand form", {
  expect_equal(
    config(list(a = "x", b = "y"), "orderly.yml"),
    list(a = list(path = "x"), b = list(path = "y")))
  expect_equal(
    config(list(a = "x", b = list(path = "y")), "orderly.yml"),
    list(a = list(path = "x"), b = list(path = "y")))
})
