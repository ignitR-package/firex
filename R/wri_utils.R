# =============================================================================
# STAC Helper Functions (Internal) — devtools::load_all() workflow
#
# ASSUMPTIONS:
# - Dev workflow (not installed) is OK
# - STAC is link-navigable:
#     catalog.json -> rel="child" to collection.json
#     collection.json -> rel="item" to items/*.json
# =============================================================================

#' Use a fallback value for `NULL`
#'
#' @param a Primary value.
#' @param b Fallback value used when `a` is `NULL`.
#'
#' @return `a` when it is not `NULL`; otherwise `b`.
#' @keywords internal
#' @noRd
`%||%` <- function(a, b) if (!is.null(a)) a else b

# -----------------------------------------------------------------------------
# INTERNAL: REQUIRE rstac
# -----------------------------------------------------------------------------

#' Require rstac
#'
#' Checks that `rstac` is installed before reading STAC files.
#'
#' @return `NULL`, invisibly. Errors if `rstac` is not installed.
#' @keywords internal
#' @noRd
.wri_require_rstac <- function() {
  if (!requireNamespace("rstac", quietly = TRUE)) {
    stop(
      "Package 'rstac' is required. Install it with install.packages('rstac').",
      call. = FALSE
    )
  }
}

# -----------------------------------------------------------------------------
# INTERNAL: SAFELY PULL FIRST PROPERTY VALUE
# -----------------------------------------------------------------------------

#' Extract the first STAC item property value
#'
#' @param item_obj STAC item object.
#' @param key Character. Property name to extract from `item_obj$properties`.
#'
#' @return A character scalar, or `NA_character_` when the property is missing.
#' @keywords internal
#' @noRd
.wri_prop1 <- function(item_obj, key) {
  properties <- item_obj$properties
  if (is.null(properties)) return(NA_character_)

  value <- properties[[key]]
  if (is.null(value) || length(value) == 0) return(NA_character_)

  as.character(value[[1]])
}

# -----------------------------------------------------------------------------
# GET PACKAGE PATH (DEV MODE)
# -----------------------------------------------------------------------------

#' Resolve the package path in development mode
#'
#' @return A normalized package root path.
#' @keywords internal
#' @noRd
wri_get_pkg_path <- function() {

  if (!requireNamespace("pkgload", quietly = TRUE)) {
    stop(
      "Dev mode required: install 'pkgload' and load with devtools::load_all().\n",
      "Install: install.packages('pkgload')",
      call. = FALSE
    )
  }

  pkg_path <- tryCatch(pkgload::pkg_path(), error = function(e) NA_character_)

  if (!is.na(pkg_path) && nzchar(pkg_path) && dir.exists(pkg_path)) {
    return(normalizePath(pkg_path, winslash = "/", mustWork = TRUE))
  }

  stop(
    "Could not determine package path in dev mode.\n\n",
    "Run this from the package root (folder with DESCRIPTION):\n",
    "  setwd('~/MEDS/Capstone/firex')\n",
    "  devtools::load_all()\n",
    call. = FALSE
  )
}

# -----------------------------------------------------------------------------
# RESOLVE STAC CATALOG PATH
# -----------------------------------------------------------------------------

#' Resolve the local STAC catalog path
#'
#' @return A normalized path to `inst/extdata/stac/catalog.json`.
#' @keywords internal
#' @noRd
wri_resolve_stac_path <- function() {

  pkg_path <- tryCatch(
    wri_get_pkg_path(),
    error = function(e) NA_character_
  )

  # First look for a catalog in the package's inst/extdata/stac/ directory (dev mode)
  dev_stac_path <- if (!is.na(pkg_path) && nzchar(pkg_path)) {
    normalizePath(
      file.path(pkg_path, "inst", "extdata", "stac", "catalog.json"),
      winslash = "/",
      mustWork = FALSE
    )
  } else {
    NA_character_
  }

  installed_stac_path <- system.file("extdata", "stac", "catalog.json", package = "firex")

  if (!is.na(dev_stac_path) && file.exists(dev_stac_path)) {
    return(dev_stac_path)
  }

  if (nzchar(installed_stac_path) && file.exists(installed_stac_path)) {
    return(normalizePath(installed_stac_path, winslash = "/", mustWork = TRUE))
  }

  dev_label <- if (!is.na(dev_stac_path) && nzchar(dev_stac_path)) {
    dev_stac_path
  } else {
    "<package root could not be resolved>"
  }

  installed_label <- if (nzchar(installed_stac_path)) {
    normalizePath(installed_stac_path, winslash = "/", mustWork = FALSE)
  } else {
    "<installed package extdata/stac/catalog.json not found>"
  }

  stop(
    "STAC catalog not found.\n\n",
    "I looked for:\n  ", dev_label, "\n ", installed_label, "\n\n",
    "Expected locations:\n",
    "  <pkg_root>/inst/extdata/stac/catalog.json\n",
    "  <installed firex>/extdata/stac/catalog.json\n",
    call. = FALSE
  )
}

# -----------------------------------------------------------------------------
# RESOLVE HREF (RELATIVE / ABSOLUTE / URL)
# -----------------------------------------------------------------------------

#' Resolve a STAC href
#'
#' @param base_file Character. Path to the STAC file containing the href.
#' @param href Character. Relative path, absolute path, or URL to resolve.
#'
#' @return A character path or URL, or `NA_character_` for missing hrefs.
#' @keywords internal
#' @noRd
wri_resolve_href <- function(base_file, href) {

  if (is.null(href) || !nzchar(href)) {
    return(NA_character_)
  }

  if (grepl("^[a-zA-Z]+://", href)) {
    return(href)
  }

  if (grepl("^/", href)) {
    return(normalizePath(href, winslash = "/", mustWork = FALSE))
  }

  normalizePath(
    file.path(dirname(base_file), href),
    winslash = "/",
    mustWork = FALSE
  )
}

# -----------------------------------------------------------------------------
# FILTER LINKS BY REL TYPE
# -----------------------------------------------------------------------------

#' Filter STAC links by relation type
#'
#' @param stac_obj STAC object containing a `links` list.
#' @param rel Character. Link relation value to keep.
#'
#' @return A list of matching STAC link objects.
#' @keywords internal
#' @noRd
wri_links_by_rel <- function(stac_obj, rel) {

  links <- stac_obj$links
  if (is.null(links) || length(links) == 0) {
    return(list())
  }

  keep <- vapply(
    links,
    function(link_obj) identical(link_obj$rel, rel),
    logical(1)
  )

  links[keep]
}

# -----------------------------------------------------------------------------
# EXTRACT ASSETS FROM STAC ITEM (DATA FRAME)
# -----------------------------------------------------------------------------

#' Extract STAC item assets as a data frame
#'
#' @param item_obj STAC item object.
#' @param item_file Character. Path to the source item file.
#'
#' @return A data frame with one row per asset.
#' @keywords internal
#' @noRd
wri_item_assets_df <- function(item_obj, item_file) {

  assets <- item_obj$assets

  if (is.null(assets) || length(assets) == 0) {
    return(data.frame(
      asset_name = character(),
      href = character(),
      type = character(),
      roles = I(list()),
      stringsAsFactors = FALSE
    ))
  }

  out <- lapply(names(assets), function(asset_name) {

    asset_obj <- assets[[asset_name]]

    data.frame(
      asset_name = asset_name,
      href = if (!is.null(asset_obj$href)) {
        wri_resolve_href(item_file, asset_obj$href)
      } else {
        NA_character_
      },
      type = if (!is.null(asset_obj$type)) asset_obj$type else NA_character_,
      roles = I(list(if (!is.null(asset_obj$roles)) asset_obj$roles else character())),
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, out)
}

# -----------------------------------------------------------------------------
# READ ROOT STAC
# -----------------------------------------------------------------------------

#' Read the root STAC catalog
#'
#' @return A STAC object returned by `rstac::read_stac()`.
#' @keywords internal
#' @noRd
wri_read_stac_root <- function() {
  .wri_require_rstac()
  stac_path <- wri_resolve_stac_path()
  rstac::read_stac(stac_path)
}

# -----------------------------------------------------------------------------
# READ FULL STAC TREE
# -----------------------------------------------------------------------------

#' Read the full linked STAC tree
#'
#' Follows child and item links from the root STAC catalog and gathers
#' collection and item metadata.
#'
#' @return A list with `catalog_path`, `catalog`, `collections`, and `items`.
#' @keywords internal
#' @noRd
wri_read_stac_tree <- function() {

  .wri_require_rstac()

  catalog_path <- wri_resolve_stac_path()
  visited <- new.env(parent = emptyenv())

  read_file <- function(path) {

    path <- normalizePath(path, winslash = "/", mustWork = FALSE)

    if (exists(path, envir = visited, inherits = FALSE)) {
      return(get(path, envir = visited, inherits = FALSE))
    }

    stac_obj <- rstac::read_stac(path)
    assign(path, stac_obj, envir = visited)
    stac_obj
  }

  catalog <- read_file(catalog_path)

  child_links <- wri_links_by_rel(catalog, "child")
  child_paths <- unique(
    vapply(
      child_links,
      function(link_obj) wri_resolve_href(catalog_path, link_obj$href),
      character(1)
    )
  )

  collections <- list()
  items <- list()

  for (collection_path in child_paths) {

    if (is.na(collection_path) || !file.exists(collection_path)) next

    collection_obj <- read_file(collection_path)

    collection_id <- if (!is.null(collection_obj$id) && nzchar(collection_obj$id)) {
      collection_obj$id
    } else {
      basename(dirname(collection_path))
    }

    item_links <- c(
      wri_links_by_rel(collection_obj, "item"),
      wri_links_by_rel(collection_obj, "child")
    )

    item_paths <- unique(
      vapply(
        item_links,
        function(link_obj) wri_resolve_href(collection_path, link_obj$href),
        character(1)
      )
    )

    if (length(item_paths) == 0) {
      stop(
        "No items discovered for collection '", collection_id, "'.\n",
        "Expected rel='item' links in:\n  ", collection_path,
        call. = FALSE
      )
    }

    collection_item_ids <- character()

    for (j in seq_along(item_paths)) {

      item_path <- item_paths[j]

      if (is.na(item_path) || !file.exists(item_path)) next

      item_obj <- read_file(item_path)

      # Keep only STAC Items
      if (!is.null(item_obj$type) && !identical(item_obj$type, "Feature")) next

      item_id <- item_obj$id
      if (is.null(item_id) || !nzchar(item_id)) {
        item_id <- tools::file_path_sans_ext(basename(item_path))
      }

      items[[item_id]] <- list(
        id = item_id,
        collection = collection_id,
        item_path = item_path,
        item_order_in_collection = j,
        item = item_obj,
        assets = wri_item_assets_df(item_obj, item_path)
      )

      collection_item_ids <- c(collection_item_ids, item_id)
    }

    collections[[collection_id]] <- list(
      id = collection_id,
      collection_path = collection_path,
      collection = collection_obj,
      item_ids = unique(collection_item_ids)
    )
  }

  list(
    catalog_path = catalog_path,
    catalog = catalog,
    collections = collections,
    items = items
  )
}

#' Flatten STAC item metadata
#'
#' @param data A list returned by `wri_read_stac_tree()`.
#'
#' @return A data frame with one row per asset or layer.
#' @keywords internal
#' @noRd
wri_items_df <- function(data) {

  if (is.null(data$items) || length(data$items) == 0) {
    return(data.frame())
  }

  out <- lapply(seq_along(data$items), function(i) {

    item_wrapper <- data$items[[i]]
    item_obj <- item_wrapper$item
    bbox <- item_obj$bbox %||% rep(NA_real_, 4)
    xmin <- if (length(bbox) >= 1) as.numeric(bbox[1]) else NA_real_
    ymin <- if (length(bbox) >= 2) as.numeric(bbox[2]) else NA_real_
    xmax <- if (length(bbox) >= 3) as.numeric(bbox[3]) else NA_real_
    ymax <- if (length(bbox) >= 4) as.numeric(bbox[4]) else NA_real_

    assets <- item_wrapper$assets

    if (is.null(assets) || nrow(assets) == 0) {
      return(data.frame(

        id = item_wrapper$id,
        collection = item_wrapper$collection,
        item_path = item_wrapper$item_path,
        asset_name = NA_character_,
        asset_href = NA_character_,
        asset_type = NA_character_,
        datetime = .wri_prop1(item_obj, "datetime"),
        proj_code = .wri_prop1(item_obj, "proj:code"),
        data_type = .wri_prop1(item_obj, "data_type"),
        wri_domain = .wri_prop1(item_obj, "wri_domain"),
        wri_dimension = .wri_prop1(item_obj, "wri_dimension"),
        is_hosted = .wri_prop1(item_obj, "is_hosted"),
        xmin = xmin,
        ymin = ymin,
        xmax = xmax,
        ymax = ymax,
        stringsAsFactors = FALSE
      ))
    }

    data.frame(

      id = item_wrapper$id,
      collection = item_wrapper$collection,
      # item_path = item_wrapper$item_path, enable if data is ever stored locally
      asset_name = assets$asset_name,
      asset_href = assets$href,
      asset_type = assets$type,
      datetime = .wri_prop1(item_obj, "datetime"),
      proj_code = .wri_prop1(item_obj, "proj:code"),
      data_type = .wri_prop1(item_obj, "data_type"),
      wri_domain = .wri_prop1(item_obj, "wri_domain"),
      wri_dimension = .wri_prop1(item_obj, "wri_dimension"),
      is_hosted = .wri_prop1(item_obj, "is_hosted"),
      xmin = xmin,
      ymin = ymin,
      xmax = xmax,
      ymax = ymax,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, out)
}

# -----------------------------------------------------------------------------
# PICK HOSTED COG RASTER ASSET FROM ITEM ROWS (should non-hosted, non-COG data be added in the future)
# -----------------------------------------------------------------------------

#' Pick a hosted raster asset
#'
#' @param df Data frame of layer asset rows.
#'
#' @return A one-row data frame for the selected raster asset, or an empty data
#'   frame when no raster asset is available.
#' @keywords internal
#' @noRd
.wri_pick_raster_asset <- function(df) {

  if (is.null(df) || nrow(df) == 0) {
    return(df)
  }

  # Pick COG asset
  is_raster <- grepl("geotiff", df$asset_type, ignore.case = TRUE)

  candidates <- df[is_raster, , drop = FALSE]

  if (nrow(candidates) == 0) {
    return(df[0, , drop = FALSE])
  }

  # Prefer hosted assets if available
  if ("is_hosted" %in% names(candidates)) {
    hosted <- candidates[tolower(as.character(candidates$is_hosted)) == "true", , drop = FALSE]
    if (nrow(hosted) > 0) {
      candidates <- hosted
    }
  }

  # Return best match (first row)
  candidates[1, , drop = FALSE]
}

# -----------------------------------------------------------------------------
# HELPER TO CREATE A STRUCTURED RESULT WITH A MESSAGE ATTRIBUTE
# -----------------------------------------------------------------------------

#' Create a structured logical result
#'
#' @param value Logical value for the result.
#' @param message Optional character message.
#' @param status Optional character status label.
#' @param bbox Optional bounding box attribute.
#' @param extent Optional extent attribute.
#' @param crs Optional CRS attribute.
#' @param aoi Optional area-of-interest attribute.
#' @param type Optional input type attribute.
#'
#' @return A length-1 logical with the supplied attributes attached.
#' @keywords internal
#' @noRd
.make_result <- function(value,
                         message = NULL,
                         status = NULL,
                         bbox = NULL,
                         extent = NULL,
                         crs = NULL,
                         aoi = NULL,
                         type = NULL) {
  structure(
    as.logical(value),
    message = message,
    status = status,
    bbox = bbox,
    extent = extent,
    crs = crs,
    aoi = aoi,
    type = type
  )
}
