.onLoad <- function(...) {
  # nocov start
  orderly2::orderly_plugin_register(
    "orderly.sharedfile",
    config = config,
    serialise = serialise,
    schema = "orderly.sharedfile.json")
  # nocov end
}
