get_layer <- function(id, aoi = NULL, aoi_crs = NULL) {

  bbox <- NULL
  aoi_geom <- NULL

  # Validate layer id
  if (missing(id) || !is.character(id) || length(id) != 1 || !nzchar(id)) {
    stop(
      "`id` must be a single non-empty character string.",
      call. = FALSE
    )
  }

  # Resolve AOI pipeline:
  # - coerce to terra object
  # - resolve CRS
  # - project to EPSG:4326
  # - extract bbox
  if (!is.null(aoi)) {

    aoi_result <- resolve_aoi(
      aoi = aoi,
      aoi_crs = aoi_crs,
      target_crs = "EPSG:4326"
    )

    if (!isTRUE(aoi_result)) {
      stop(attr(aoi_result, "message"), call. = FALSE)
    }

    # Final AOI geometry projected to EPSG:4326
    aoi_geom <- attr(aoi_result, "aoi")

    # Final bbox in STAC/API order:
    # c(xmin, ymin, xmax, ymax)
    bbox <- attr(aoi_result, "bbox")
  }

  # Retrieve layer metadata
  layer <- layer_info(id)

  # Keep only raster asset
  layer <- .wri_pick_raster_asset(layer)

  if (nrow(layer) == 0) {
    stop(
      "No raster asset found for layer '", id, "'.",
      call. = FALSE
    )
  }

  # Ensure asset is hosted
  is_hosted <- tolower(as.character(layer$is_hosted[1])) == "true"

  if (!is_hosted) {
    stop(
      "Layer '", id, "' is not hosted and cannot be streamed.",
      call. = FALSE
    )
  }

  # Check AOI overlap against layer extent metadata
  if (!is.null(bbox)) {

    # Layer metadata bbox already stored in EPSG:4326
    layer_bbox <- c(
      layer$xmin[1],
      layer$ymin[1],
      layer$xmax[1],
      layer$ymax[1]
    )

    if (anyNA(layer_bbox)) {
      stop(
        "Layer extent metadata is missing for layer '",
        id,
        "'.",
        call. = FALSE
      )
    }

    overlap_check <- check_extent_overlap(
      bbox,
      layer_bbox
    )

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

  # Build GDAL VSI path for COG streaming
  vsi_path <- paste0("/vsicurl/", href)

  tryCatch({

    # Stream raster
    rast <- terra::rast(vsi_path)

    # Crop if AOI provided
    if (!is.null(bbox)) {

      # Convert STAC/API bbox order:
      # xmin, ymin, xmax, ymax
      #
      # into terra::ext() order:
      # xmin, xmax, ymin, ymax
      bbox_ext <- terra::ext(
        bbox[1],
        bbox[3],
        bbox[2],
        bbox[4]
      )

      # Convert extent into polygon geometry
      # so reprojection is spatially correct
      bbox_vect <- terra::as.polygons(
        bbox_ext,
        crs = "EPSG:4326"
      )

      # Project AOI polygon into raster CRS
      bbox_vect <- terra::project(
        bbox_vect,
        terra::crs(rast)
      )

      # Crop raster to projected AOI bbox
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