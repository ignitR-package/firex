#' Get a WRI raster layer
#'
#' Retrieves a hosted WRI raster asset and optionally crops it to a spatial
#' area of interest. The area of interest can be supplied in several formats:
#' a numeric bounding box, a file path to a shapefile or GeoJSON, an
#' \code{sf} object, or a \code{terra} spatial object
#' (\code{SpatVector}, \code{SpatRaster}, or \code{SpatExtent}).
#'
#' @param id Character. Layer id to retrieve. See \code{\link{wri_overview_df}}
#'   for available ids.
#' @param aoi Area of interest used to crop the layer. Accepted inputs:
#'   \itemize{
#'     \item \code{NULL} — returns the full global layer (default).
#'     \item Numeric vector \code{c(xmin, ymin, xmax, ymax)} — bounding box;
#'       \code{aoi_crs} is required.
#'     \item Character path to a shapefile (\code{.shp}) or GeoJSON file.
#'     \item An \code{sf} or \code{sfc} object.
#'     \item A \code{terra::SpatVector}, \code{terra::SpatRaster}, or
#'       \code{terra::SpatExtent}.
#'   }
#' @param aoi_crs Character or integer CRS specification (e.g.
#'   \code{"EPSG:4326"} or \code{4326}). Required when \code{aoi} is a
#'   numeric bounding box or a CRS-less spatial object; must be omitted when
#'   \code{aoi} already carries a CRS.
#'
#' @returns A \code{terra::SpatRaster} cropped to \code{aoi}, or the full
#'   layer when \code{aoi = NULL}.
#'
#' @seealso \code{\link{resolve_to_bbox}}, \code{\link{normalize_crs}},
#'   \code{\link{wri_overview_df}}
#' @export
#'
#' @examples
#' \dontrun{
#' # Full layer
#' wri <- get_layer("WRI_score")
#'
#' # Numeric bbox (WGS 84)
#' wri_norcal <- get_layer("WRI_score",
#'                         aoi     = c(-122, 37, -121, 38),
#'                         aoi_crs = "EPSG:4326")
#'
#' # Shapefile path
#' shp <- system.file("demos/data/Eaton_Perimeter_20250121.shp",
#'                    package = "firex")
#' wri_eaton <- get_layer("WRI_score", aoi = shp)
#' }
get_layer <- function(id, aoi = NULL, aoi_crs = NULL) {
  bbox <- NULL

  if (missing(id) || !is.character(id) || length(id) != 1 || !nzchar(id)) {
    stop("`id` must be a single non-empty character string.", call. = FALSE)
  }

  if (!is.null(aoi)) {

    # Normalize crs if provided
    if (!is.null(aoi_crs)) {

      crs_check <- normalize_crs(aoi_crs)
      if (!isTRUE(crs_check)) stop(attr(crs_check, "message"), call. = FALSE)

      aoi_crs <- attr(crs_check, "crs")
    }

    # Resolve input to bbox
    aoi_check <- resolve_to_bbox(aoi, aoi_crs)

    if (!isTRUE(aoi_check)) stop(attr(aoi_check, "message"), call. = FALSE)
    bbox <- attr(aoi_check, "bbox")
    bbox_crs <- attr(aoi_check, "crs")

    # Validate bbox
    bbox_check <- is_valid_bbox(bbox, bbox_crs)

    if (!isTRUE(bbox_check)) stop(attr(bbox_check, "message"), call. = FALSE)
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

      # Project the user bbox to the raster CRS and apply it as a lazy window.
      bbox_projected <- terra::project(bbox_ext, from = "EPSG:4326", to = terra::crs(rast))
      terra::window(rast) <- bbox_projected
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
