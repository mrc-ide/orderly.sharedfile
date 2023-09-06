##' Return a path to a file from a shared file location. This function
##' returns the absolute path to a file (or directory) within one of
##' your collections of shared resources.
##'
##' @title Use shared files from an orderly task
##'
##' @param files A character vector of filenames
##'
##' @param from Optional string, required if you have more than one
##'   folder configured.
##'
##' @return The absolute path of the requested files, in the same
##'   order as `files`
##'
##' @export
sharedfile_path <- function(files, from = NULL) {
  ctx <- orderly2::orderly_plugin_context("orderly.sharedfile", parent.frame())
  folders <- names(ctx$config)
  if (is.null(from)) {
    if (length(folders) > 1) {
      cli::cli_abort(
        c("'from' must be given as you have more than one folder configured",
          i = "Possible values are: {squote(folders)}"))
    } else {
      from <- folders
    }
  } else {
    from <- match_value(from, folders)
  }
  from_path <- ctx$config[[from]]$path
  is_missing <- file_exists(files, workdir = from_path)
  if (any(is_missing)) {
    cli::cli_abort(
      c("File in '{from}' does not exist: {squote(files[is_missing])}",
        i = "Root for '{from}' is '{from_path}'"))
  }

  hash_algorithm <- orderly2::orderly_config(ctx$root)$core$hash_algorithm
  path_expanded <- expand_dirs(files, from_path)
  hash <- withr::with_dir(
    from_path,
    vcapply(path_expanded, hash_file, hash_algorithm))
  info <- data_frame(from = from,
                     path = path_expanded,
                     hash = unname(hash))

  orderly2::orderly_plugin_add_metadata("orderly.sharedfile", "path", info)
  file.path(from_path, files)
}
