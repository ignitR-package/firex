#' Get a WRI raster layer
#'
#' @param id Character. Layer id to retrieve.
#' @param bbox Numeric vector `c(xmin, ymin, xmax, ymax)` in the supplied
#'   `crs`. If `NULL`, returns the full layer.
#' @param crs Character. Coordinate reference system of `bbox`. Defaults to
#'   `"EPSG:4326"`.
#'
#' @returns A `terra::SpatRaster`.
#' @export
#'
#' @examples
#' \dontrun{
#' bbox <- c(-122, 37, -121, 38)
#' rast <- get_layer("WRI_score", bbox = bbox)
#' }
get_layer <- function(id, bbox = NULL, crs = "EPSG:4326") {
  if (missing(id) || !is.character(id) || length(id) != 1 || !nzchar(id)) {
    stop("`id` must be a single non-empty character string.", call. = FALSE)
  }

  if (!is.null(bbox)) {
    bbox_check <- is_valid_bbox(bbox, crs)

    if (!isTRUE(bbox_check)) {
      stop(attr(bbox_check, "message"), call. = FALSE)
    }

    bbox <- attr(bbox_check, "bbox")
  }

  # Get layer metadata (asset-level)
  layer <- layer_info(id)

  # Check layer exists
  layer <- .wri_pick_raster_asset(layer)

  if (nrow(layer) == 0) {
    stop(
      "No raster asset found for layer '", id, "'.",
      call. = FALSE
    )
  }

  # Ensure it's hosted
  is_hosted <- tolower(as.character(layer$is_hosted[1])) == "true"

  if (!is_hosted) {
    stop(
      "Layer '", id, "' is not hosted and cannot be streamed.",
      call. = FALSE
    )
  }

  if (!is.null(bbox)) {

    # extract layer bbox (in EPSG:4326)
    layer_bbox <- c(layer$xmin[1], layer$ymin[1], layer$xmax[1], layer$ymax[1])
    
    if (anyNA(layer_bbox)) {
      stop("Layer extent metadata is missing for layer '", id, "'.", call. = FALSE)
    }

    overlap_check <- check_extent_overlap(bbox, layer_bbox)
    overlap_status <- attr(overlap_check, "status")
    overlap_message <- attr(overlap_check, "message")

    if (identical(overlap_status, "none")) {
      stop(overlap_message, call. = FALSE)
    }

    if (identical(overlap_status, "partial")) {
      warning(overlap_message, call. = FALSE)
    }
  }

  href <- layer$asset_href[1]

  # Build GDAL VSI path (COG streaming)
  vsi_path <- paste0("/vsicurl/", href)

  tryCatch({

    rast <- terra::rast(vsi_path)

    if (!is.null(bbox)) {

      # extract spatial extent of user bbox
      bbox_ext <- terra::ext(bbox[1], bbox[3], bbox[2], bbox[4])
      
      # project user bbox to match raster crs (5070)
      bbox_projected <- terra::project(bbox_ext, from = "EPSG:4326", to = terra::crs(rast))

      # convert projected bbox to a SpatVector polygon for cropping
      bbox_vect <- terra::as.polygons(bbox_projected, crs = terra::crs(rast))

      # crop the raster to the projected bbox
      rast <- terra::crop(rast, bbox_vect)
    }

    rast

  }, error = function(e) {
    stop(
      "Failed to retrieve layer '", id, "'.\n",
      "URL: ", href, "\n",
      "Error: ", conditionMessage(e),
      call. = FALSE
    )
  })
}

