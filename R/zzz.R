.onLoad <- function(...) {
  # nocov start
  orderly::orderly_plugin_register(
    "orderly.sharedfile",
    config = config,
    serialise = serialise,
    schema = "orderly.sharedfile.json")
  # nocov end
}
