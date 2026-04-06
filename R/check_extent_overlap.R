#' Check whether a bounding box falls within a layer extent
#'
#' Checks whether a requested bounding box is fully contained within the
#' extent of a STAC layer.
#'
#' @param bbox Numeric vector in the form \code{c(xmin, ymin, xmax, ymax)}
#'   in EPSG:4326.
#' @param layer_id Character. A single layer ID to check against.
#'
#' @return A length-1 logical. Returns \code{TRUE} when \code{bbox} is fully
#'   contained within the requested layer extent and \code{FALSE} otherwise.
#'   The return value carries a \code{"message"} attribute that can be read
#'   later with \code{attr(result, "message")}.
#'
#' @details Overlap outcomes:
#' \itemize{
#' \item Full overlap - returns \code{TRUE}
#' \item Partial overlap - returns \code{FALSE} with a message describing
#'   which side of the layer extent the bbox exceeds
#' \item No overlap - returns \code{FALSE} with a message that the bbox does
#'   not overlap the layer extent
#' }
#'
#' @keywords internal
check_extent_overlap <- function(bbox, layer_id) {
  make_result <- function(value, message = NULL) {
    structure(as.logical(value), message = message)
  }

  if (missing(layer_id) || is.null(layer_id) || length(layer_id) != 1L || !nzchar(layer_id)) {
    return(make_result(FALSE, "A single layer_id is required."))
  }

  bbox_check <- is_valid_bbox(bbox)
  if (!isTRUE(bbox_check)) {
    return(make_result(FALSE, paste0("Invalid bounding box: ", bbox_check)))
  }

  layer_bbox <- .get_layer_bbox(layer_id)
  if (is.null(layer_bbox)) {
    return(make_result(FALSE, paste0("Layer '", layer_id, "' not found in the STAC catalog.")))
  }

  is_within_extent <- bbox[1] >= layer_bbox[1] &&
    bbox[2] >= layer_bbox[2] &&
    bbox[3] <= layer_bbox[3] &&
    bbox[4] <= layer_bbox[4]

  if (is_within_extent) {
    return(make_result(TRUE))
  }

  has_overlap <- bbox[1] < layer_bbox[3] &&
    bbox[3] > layer_bbox[1] &&
    bbox[2] < layer_bbox[4] &&
    bbox[4] > layer_bbox[2]

  outside_sides <- c(
    left = bbox[1] < layer_bbox[1],
    bottom = bbox[2] < layer_bbox[2],
    right = bbox[3] > layer_bbox[3],
    top = bbox[4] > layer_bbox[4]
  )

  if (has_overlap) {
    side_text <- paste(names(outside_sides)[outside_sides], collapse = ", ")
    message <- paste0(
      "Requested bbox extends outside layer '", layer_id,
      "' extent on the ", side_text, "."
    )

    return(make_result(FALSE, message))
  }

  make_result(
    FALSE,
    paste0("Requested bbox does not overlap layer '", layer_id, "' extent.")
  )
}

.get_layer_bbox <- function(layer_id) {
  layer_bbox <- .get_layer_bbox_from_loaded_items(layer_id)
  if (!is.null(layer_bbox)) {
    return(layer_bbox)
  }

  stac_dirs <- .get_stac_item_dirs()
  if (length(stac_dirs) == 0) {
    return(NULL)
  }

  for (stac_dir in stac_dirs) {
    stac_file <- file.path(stac_dir, paste0(layer_id, ".json"))

    if (!file.exists(stac_file)) {
      next
    }

    item <- jsonlite::read_json(stac_file)
    layer_bbox <- as.numeric(unlist(item$bbox, use.names = FALSE))

    if (length(layer_bbox) == 4L) {
      return(layer_bbox)
    }
  }

  NULL
}

.get_layer_bbox_from_loaded_items <- function(layer_id) {
  if (!exists("load_stac_items", mode = "function", inherits = TRUE)) {
    return(NULL)
  }

  items <- tryCatch(load_stac_items(), error = function(e) NULL)
  if (is.null(items) || length(items) == 0) {
    return(NULL)
  }

  for (item in items) {
    if (identical(item$id, layer_id)) {
      layer_bbox <- as.numeric(unlist(item$bbox, use.names = FALSE))

      if (length(layer_bbox) == 4L) {
        return(layer_bbox)
      }
    }
  }

  NULL
}

.get_stac_item_dirs <- function() {
  stac_dirs <- character(0)

  if (exists("get_stac_catalog_path", mode = "function", inherits = TRUE)) {
    kaiju_dir <- tryCatch(get_stac_catalog_path(), error = function(e) "")

    if (is.character(kaiju_dir) && length(kaiju_dir) == 1L && nzchar(kaiju_dir)) {
      stac_dirs <- c(stac_dirs, kaiju_dir)
    }
  }

  installed_dir <- system.file(
    "extdata",
    "stac",
    "collections",
    "wri_ignitR",
    "items",
    package = "firex"
  )

  stac_dirs <- c(
    stac_dirs,
    installed_dir,
    file.path("inst", "extdata", "stac", "collections", "wri_ignitR", "items")
  )

  unique(stac_dirs[nzchar(stac_dirs)])
}
