config <- function(data, filename) {
  if (length(data) == 0) {
    stop(sprintf("%s:orderly.sharedfile must contain at least one folder",
                 filename))
  }
  assert_named(data, unique = TRUE,
               name = sprintf("%s:orderly.sharedfile", filename))
  for (nm in names(data)) {
    content <- data[[nm]]
    if (is.character(content)) {
      content <- list(path = content)
    } else {
      prefix <- sprintf("%s:orderly.sharedfile:%s", filename, nm)
      check_fields(content, prefix, "path", NULL)
    }
    data[[nm]] <- content
  }
  data
}


serialise <- function(data) {
  data <- list(path = do.call("rbind", data$path))
  jsonlite::toJSON(data, auto_unbox = FALSE, pretty = FALSE, na = "null",
                   null = "null")
}
