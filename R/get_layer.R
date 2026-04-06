#' Title
#'
#' @param id
#' @param bbox
#'
#' @returns
#' @export
#'
#' @examples

get_layer <- function(id, bbox = NULL) {

  # Validate inputs
  if (missing(id) || !is.character(id) || length(id) != 1 || !nzchar(id)) {
    stop("`id` must be a single non-empty character string.", call. = FALSE)
  }

  if (!is.null(bbox)) {
    if (!is.numeric(bbox) || length(bbox) != 4) {
      stop("`bbox` must be numeric: c(xmin, ymin, xmax, ymax)", call. = FALSE)
    }
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
  is_hosted <- tolower(layer$is_hosted[1]) == "true"

  if (!is_hosted) {
    stop(
      "Layer '", id, "' is not hosted and cannot be streamed.",
      call. = FALSE
    )
  }

  href <- layer$asset_href[1]

  # Build GDAL VSI path (COG streaming)
  vsi_path <- paste0("/vsicurl/", href)

  tryCatch({

    rast <- terra::rast(vsi_path)

    if (!is.null(bbox)) {

      bbox_ext <- terra::ext(bbox[1], bbox[3], bbox[2], bbox[4])
      bbox_vect <- terra::as.polygons(bbox_ext, crs = "EPSG:4326")

      bbox_transformed <- terra::project(bbox_vect, terra::crs(rast))

      rast <- terra::crop(rast, bbox_transformed)
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

