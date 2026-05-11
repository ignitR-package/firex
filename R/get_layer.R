get_layer <- function(id, aoi = NULL, aoi_crs = NULL) {

  aoi_poly <- NULL

  if (missing(id) || !is.character(id) || length(id) != 1L || !nzchar(id)) {
    stop("`id` must be a single non-empty character string.", call. = FALSE)
  }

  if (!is.null(aoi)) {

    aoi_result <- resolve_aoi(
      aoi = aoi,
      aoi_crs = aoi_crs
    )

    if (!isTRUE(aoi_result)) {
      stop(attr(aoi_result, "message"), call. = FALSE)
    }

    aoi_poly <- attr(aoi_result, "aoi")
  }

  layer <- layer_info(id)
  layer <- .wri_pick_raster_asset(layer)

  if (nrow(layer) == 0) {
    stop("No raster asset found for layer '", id, "'.", call. = FALSE)
  }

  is_hosted <- tolower(as.character(layer$is_hosted[1])) == "true"

  if (!is_hosted) {
    stop("Layer '", id, "' is not hosted and cannot be streamed.", call. = FALSE)
  }

  href <- layer$asset_href[1]
  vsi_path <- paste0("/vsicurl/", href)

  tryCatch({

    rast <- terra::rast(vsi_path)

    if (!is.null(aoi_poly)) {

      aoi_projected <- terra::project(
        aoi_poly,
        terra::crs(rast)
      )

      rast <- terra::crop(rast, aoi_projected)
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
