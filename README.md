# orderly.sharedfile

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R build status](https://github.com/mrc-ide/orderly.sharedfile/workflows/R-CMD-check/badge.svg)](https://github.com/mrc-ide/orderly.sharedfile/actions)
[![codecov.io](https://codecov.io/github/mrc-ide/orderly.sharedfile/coverage.svg?branch=main)](https://codecov.io/github/mrc-ide/orderly.sharedfile?branch=main)
<!-- badges: end -->

This package contains a small plugin for using files from some shared location within [`orderly2`](https://mrc-ide.github.io/orderly2). Unlike [`orderly2::orderly_shared_resource`](https://mrc-ide.github.io/orderly2/reference/orderly_shared_resource.html), the assumption here is that the files are somewhere out of the source tree, for example a mounted shared drive that multiple people access.

We expect that the files are to be read into a running task/report are **read only** and are a source of information, not a destination to write things to.

## Configuration

**This may change as and when we overhaul `orderly2`'s configuration; we would like to entirely remove the yaml, and are open to suggestions.**

Edit your `orderly_config.yml` to add a section like

```yaml
plugins:
  orderly.sharedfile:
    database:
      path: /path/to/database
```

where `/path/to/database` is the full (absolute) path to the files that you want to use from within orderly tasks/reports. As a shorthand you could also write `database: /path/to/database`.

You can have more than one entry here, for example:

```yaml
plugins:
  orderly.sharedfile:
    malaria: /path/to/malaria
    dengue: /path/to/dengue
```

uses the shorthand form to set up two shared locations, one called `malaria` and the other `dengue`.

If you are not the only person that is going to be running things that use this shared resource, you will need to make it configurable per-user. The easiest way to do this is to set paths within a file `orderly_envir.yml` (which should be excluded git) and reference environment variables from here within the configuration.  So for example you might have an `orderly_envir.yml` that contains:

```yaml
PATH_MALARIA: /path/to/malaria
PATH_DENGUE: /path/to/dengue
```

and then within the `orderly_config.yml`:

```yaml
plugins:
  orderly.sharedfile:
    malaria: $PATH_MALARIA
    dengue: $PATH_DENGUE
```

## Usage

After the plugin is configured as above, you can use it from a task/report:

```r
path_db <- orderly.sharedfile::sharedfile_path(
  "database/v1.mdb", from = "malaria")
```

The `from` argument is optional if you only have a single shared location configured. After running this statement, the variable `path_db` contains the absolute path to your database and you can pass this your db driver.

You might use a similar approach to access large shapefiles, genomic sequences, etc.

You can return vectors of paths, for example:

```r
path <- orderly.sharedfile::sharedfile_path(c("a", "b"))
```

will return a vector of length two, with the paths for files `a` and `b` in a configuration that uses only a single shared directory.

## Metadata

We save the hash of all files found, along with their full names. If the returned path is a directory, all contents are hashed.

## Installation

To install `orderly.sharedfile`:

```r
remotes::install_github("mrc-ide/orderly.sharedfile", upgrade = FALSE)
```

## License

MIT © Imperial College of Science, Technology and Medicine
