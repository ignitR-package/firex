#' Resolve an area of interest
#'
#' Converts supported area-of-interest inputs to a `terra` polygon, bounding
#' box, extent, and CRS.
#'
#' @param aoi Area of interest. Accepted inputs include `NULL`, a numeric vector
#'   `c(xmin, ymin, xmax, ymax)`, a `terra::SpatExtent`, a file path, or a
#'   spatial object that can be converted with `terra::vect()` or
#'   `terra::rast()`.
#' @param aoi_crs Optional character or integer CRS specification for `aoi`,
#'   such as `"EPSG:4326"` or `4326`.
#'
#' @return A length-1 logical with result metadata stored in attributes,
#'   including `"aoi"`, `"bbox"`, `"extent"`, `"crs"`, `"type"`, and
#'   `"message"` when validation fails.
#' @keywords internal
resolve_aoi <- function(aoi, aoi_crs = NULL) {

  if (is.null(aoi)) {
    return(.make_result(TRUE, aoi = NULL, bbox = NULL, extent = NULL, crs = NULL))
  }

  crs_result <- resolve_aoi_crs(aoi, aoi_crs)

  if (!isTRUE(crs_result)) {
    return(crs_result)
  }

  resolved_crs <- attr(crs_result, "crs")

  if (is.numeric(aoi) && length(aoi) == 4L) {

    # User/package bbox order: c(xmin, ymin, xmax, ymax)
    # terra::ext() order: xmin, xmax, ymin, ymax
    extent <- terra::ext(
      aoi[1],
      aoi[3],
      aoi[2],
      aoi[4]
    )

    input_type <- "bbox"

  } else if (inherits(aoi, "SpatExtent")) {

    extent <- aoi
    input_type <- "extent"

  } else {

    obj <- tryCatch(
      {
        if (inherits(aoi, c("SpatVector", "SpatRaster"))) {
          aoi
        } else if (inherits(aoi, c("RasterLayer", "RasterStack", "RasterBrick"))) {
          terra::rast(aoi)
        } else {
          terra::vect(aoi)
        }
      },
      error = function(e) NULL
    )

    if (is.null(obj)) {
      return(.make_result(
        FALSE,
        message = "`aoi` could not be converted to a terra-compatible spatial object."
      ))
    }

    extent <- tryCatch(
      terra::ext(obj),
      error = function(e) NULL
    )

    input_type <- class(obj)[1]
  }

  if (is.null(extent)) {
    return(.make_result(
      FALSE,
      message = "Could not extract extent from `aoi`."
    ))
  }

  if (extent$xmin >= extent$xmax || extent$ymin >= extent$ymax) {
    return(.make_result(
      FALSE,
      message = "`aoi` has zero-area extent. Single points are not valid AOIs unless buffered."
    ))
  }

  aoi_poly <- tryCatch(
    terra::as.polygons(extent),
    error = function(e) NULL
  )

  if (is.null(aoi_poly)) {
    return(.make_result(
      FALSE,
      message = "Could not convert AOI extent to polygon."
    ))
  }

  terra::crs(aoi_poly) <- resolved_crs

  bbox <- c(
    xmin = extent$xmin,
    ymin = extent$ymin,
    xmax = extent$xmax,
    ymax = extent$ymax
  )

  .make_result(
    TRUE,
    aoi = aoi_poly,
    bbox = bbox,
    extent = extent,
    crs = terra::crs(aoi_poly),
    type = input_type
  )
}
