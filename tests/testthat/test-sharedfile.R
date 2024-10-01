test_that("can copy files in from shared directory", {
  root <- withr::local_tempfile()
  shared <- withr::local_tempdir()
  saveRDS(mtcars, file.path(shared, "mtcars.rds"))
  hash <- hash_file(file.path(shared, "mtcars.rds"), "sha256")

  suppressMessages(orderly2::orderly_init(root))
  cfg <- c("minimum_orderly_version: 1.99.3",
           "plugins:",
           "  orderly.sharedfile:",
           "    incoming:",
           sprintf("      path: '%s'", shared))
  writeLines(cfg, file.path(root, "orderly_config.yml"))

  path_src <- file.path(root, "src", "example")
  fs::dir_create(path_src)
  code <- c(
    'p <- orderly.sharedfile::sharedfile_path("mtcars.rds")',
    'saveRDS(readRDS(p), "result.rds")')
  writeLines(code, file.path(path_src, "example.R"))
  id <- suppressMessages(
    orderly2::orderly_run("example", root = root, echo = FALSE))
  expect_type(id, "character")

  meta <- orderly2::orderly_metadata(id, root = root)
  expect_length(meta$custom$orderly.sharedfile$path, 1)
  expect_equal(meta$custom$orderly.sharedfile$path[[1]],
               list(from = "incoming", path = "mtcars.rds", hash = hash))
  expect_true(hash %in% meta$files$hash)
})


test_that("match folder location if needed", {
  root <- withr::local_tempfile()
  shared1 <- withr::local_tempdir()
  saveRDS(mtcars, file.path(shared1, "mtcars.rds"))
  shared2 <- withr::local_tempdir()
  saveRDS(iris, file.path(shared2, "iris.rds"))

  suppressMessages(orderly2::orderly_init(root))
  cfg <- c("minimum_orderly_version: 1.99.3",
           "plugins:",
           "  orderly.sharedfile:",
           "    shared1:",
           sprintf("      path: '%s'", shared1),
           "    shared2:",
           sprintf("      path: '%s'", shared2))
  writeLines(cfg, file.path(root, "orderly_config.yml"))

  path_src <- file.path(root, "src", "example")
  fs::dir_create(path_src)

  code <- c(
    'p <- orderly.sharedfile::sharedfile_path("mtcars.rds")',
    'saveRDS(readRDS(p), "result.rds")')
  writeLines(code, file.path(path_src, "example.R"))
  err <- expect_error(
    suppressMessages(
      orderly2::orderly_run("example", root = root, echo = FALSE)),
    "'from' must be given as you have more than one folder configured")
  expect_equal(err$parent$body,
               c(i = "Possible values are: 'shared1' and 'shared2'"))

  code <- c(
    'p <- orderly.sharedfile::sharedfile_path("mtcars.rds", "other")',
    'saveRDS(readRDS(p), "result.rds")')
  writeLines(code, file.path(path_src, "example.R"))
  expect_error(
    suppressMessages(
      orderly2::orderly_run("example", root = root, echo = FALSE)),
    "'from' must be one of 'shared1', 'shared2'")

  code <- c(
    'p <- orderly.sharedfile::sharedfile_path("mtcars.rds", "shared2")',
    'saveRDS(readRDS(p), "result.rds")')
  writeLines(code, file.path(path_src, "example.R"))
  expect_error(
    suppressMessages(
      orderly2::orderly_run("example", root = root, echo = FALSE)),
    "File in 'shared2' does not exist: 'mtcars.rds'")

  code <- c(
    'p <- orderly.sharedfile::sharedfile_path("mtcars.rds", "shared1")',
    'saveRDS(readRDS(p), "result.rds")')
  writeLines(code, file.path(path_src, "example.R"))
  id <- suppressMessages(
      orderly2::orderly_run("example", root = root, echo = FALSE))
  expect_type(id, "character")
})


test_that("can hash a directory if requested", {
  root <- withr::local_tempfile()
  shared <- withr::local_tempdir()
  fs::dir_create(file.path(shared, "x/y/z"))
  for (i in letters[1:3]) {
    writeLines(i, file.path(shared, "x/y/z", i))
  }

  suppressMessages(orderly2::orderly_init(root))
  cfg <- c("minimum_orderly_version: 1.99.3",
           "plugins:",
           "  orderly.sharedfile:",
           "    incoming:",
           sprintf("      path: '%s'", shared))
  writeLines(cfg, file.path(root, "orderly_config.yml"))

  path_src <- file.path(root, "src", "example")
  fs::dir_create(path_src)
  code <- c(
    'p <- orderly.sharedfile::sharedfile_path("x")',
    'writeLines(readLines(file.path(p, "y/z/a")), "result.txt")')
  writeLines(code, file.path(path_src, "example.R"))
  id <- suppressMessages(
    orderly2::orderly_run("example", root = root, echo = FALSE))
  expect_type(id, "character")

  meta <- orderly2::orderly_metadata(id, root = root)
  expect_length(meta$custom$orderly.sharedfile$path, 3)
  expect_setequal(
    vcapply(meta$custom$orderly.sharedfile$path, "[[", "path"),
    file.path("x/y/z", letters[1:3]))
})


test_that("can use environment variables as paths", {
  root <- withr::local_tempfile()
  shared <- withr::local_tempdir()
  saveRDS(mtcars, file.path(shared, "mtcars.rds"))
  hash <- hash_file(file.path(shared, "mtcars.rds"), "sha256")

  suppressMessages(orderly2::orderly_init(root))
  cfg <- c("minimum_orderly_version: 1.99.3",
           "plugins:",
           "  orderly.sharedfile:",
           "    incoming:",
           "      path: $PATH_SHARED")
  writeLines(cfg, file.path(root, "orderly_config.yml"))
  writeLines(sprintf("PATH_SHARED: %s", shared),
             file.path(root, "orderly_envir.yml"))

  path_src <- file.path(root, "src", "example")
  fs::dir_create(path_src)
  code <- c(
    'p <- orderly.sharedfile::sharedfile_path("mtcars.rds")',
    'saveRDS(readRDS(p), "result.rds")')
  writeLines(code, file.path(path_src, "example.R"))
  id <- suppressMessages(
    orderly2::orderly_run("example", root = root, echo = FALSE))
  expect_type(id, "character")

  meta <- orderly2::orderly_metadata(id, root = root)
  expect_length(meta$custom$orderly.sharedfile$path, 1)
  expect_equal(meta$custom$orderly.sharedfile$path[[1]],
               list(from = "incoming", path = "mtcars.rds", hash = hash))
  expect_true(hash %in% meta$files$hash)
})


test_that("can copy files in from shared directory", {
  root <- withr::local_tempfile()
  shared <- withr::local_tempdir()
  saveRDS(mtcars, file.path(shared, "mtcars.rds"))
  hash <- hash_file(file.path(shared, "mtcars.rds"), "sha256")

  suppressMessages(orderly2::orderly_init(root))
  cfg <- c("minimum_orderly_version: 1.99.3",
           "plugins:",
           "  orderly.sharedfile:",
           "    incoming:",
           sprintf("      path: '%s'", shared))
  writeLines(cfg, file.path(root, "orderly_config.yml"))

  path_src <- file.path(root, "src", "example")
  fs::dir_create(path_src)
  code <- c(
    'p <- orderly.sharedfile::sharedfile_path("mtcars.rds")',
    'saveRDS(readRDS(p), "result.rds")')
  writeLines(code, file.path(path_src, "example.R"))

  withr::with_dir(path_src, source("example.R"))
  expect_true(file.exists(file.path(path_src, "result.rds")))
  expect_equal(
    hash_file(file.path(path_src, "result.rds"), "sha256"),
    hash)
})
