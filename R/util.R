`%||%` <- function(x, y) { # nolint
  if (is.null(x)) y else x
}


squote <- function(x) {
  sprintf("'%s'", x)
}


vcapply <- function(...) {
  vapply(..., FUN.VALUE = "")
}


data_frame <- function(...) {
  data.frame(..., stringsAsFactors = FALSE, check.names = FALSE)
}


assert_named <- orderly2:::assert_named
check_fields <- orderly2:::check_fields
match_value <- orderly2:::match_value
assert_file_exists <- orderly2:::assert_file_exists
expand_dirs <- orderly2:::expand_dirs
hash_file <- orderly2:::hash_file
