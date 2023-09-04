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
  writeLines(code, file.path(path_src, "orderly.R"))
  id <- suppressMessages(
    orderly2::orderly_run("example", root = root, echo = FALSE))
  expect_type(id, "character")

  meta <- orderly2::orderly_metadata(id, root = root)
  expect_length(meta$custom$orderly.sharedfile$path, 1)
  expect_equal(meta$custom$orderly.sharedfile$path[[1]],
               list(from = "incoming", path = "mtcars.rds", hash = hash))
  expect_true(hash %in% meta$files$hash)
})
