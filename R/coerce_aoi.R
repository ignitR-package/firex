# Convert possible AOI inputs to a standardized terra format
coerce_aoi <- function(aoi) {

  # NULL is "global extent / no cropping"
  if (is.null(aoi)) {
    return(.make_result(
      TRUE,
      aoi = NULL,
      type = "null"
    ))
  }

  # Handle numeric bbox in STAC/API order:
  # c(xmin, ymin, xmax, ymax)
  if (is.numeric(aoi) && length(aoi) == 4L) {

    # terra::ext() expects:
    # xmin, xmax, ymin, ymax
    ext <- terra::ext(aoi[1], aoi[3], aoi[2], aoi[4])

    # Convert bbox extent to polygon geometry
    aoi_poly <- terra::as.polygons(ext)

    return(.make_result(
      TRUE,
      aoi = aoi_poly,
      type = "bbox"
    ))
  }

  # Handle SpatExtent objects since they have bbox structure only, not full AOI geometry
  if (inherits(aoi, "SpatExtent")) {

    poly <- tryCatch(
      terra::as.polygons(aoi),
      error = function(e) NULL
    )

    if (is.null(poly)) {
      return(.make_result(
        FALSE,
        message = "`SpatExtent` could not be converted to polygon."
      ))
    }

    return(.make_result(
      TRUE,
      aoi = poly,
      type = "extent"
    ))
  }

  # If already a terra spatial object, return as-is
  if (inherits(aoi, c("SpatVector", "SpatRaster"))) {
    return(.make_result(
      TRUE,
      aoi = aoi,
      type = class(aoi)[1]
    ))
  }

  # Handle raster package objects by converting to terra rasters
  if (inherits(aoi, c("RasterLayer", "RasterStack", "RasterBrick"))) {

    terra_aoi <- tryCatch(
      terra::rast(aoi),
      error = function(e) NULL
    )

    if (is.null(terra_aoi)) {
      return(.make_result(
        FALSE,
        message = "`raster` object could not be converted to `terra` format."
      ))
    }

    return(.make_result(
      TRUE,
      aoi = terra_aoi,
      type = class(aoi)[1]
    ))
  }

  # Attempt generic terra vector coercion
  # Handles sf/sfc objects, file paths, WKT, etc.
  obj <- tryCatch(
    terra::vect(aoi),
    error = function(e) NULL
  )

  if (is.null(obj)) {
    return(.make_result(
      FALSE,
      message = paste0(
        "`aoi` could not be coerced to a terra spatial object. ",
        "Accepted inputs include numeric bbox, SpatExtent, SpatVector, ",
        "SpatRaster, sf/sfc objects, and spatial file paths."
      )
    ))
  }

  .make_result(
    TRUE,
    aoi = obj,
    type = class(obj)[1]
  )
}