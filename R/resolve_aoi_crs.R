# Resolve CRS information for an AOI
resolve_aoi_crs <- function(aoi, aoi_crs = NULL) {

  # NULL AOI means no cropping/global layer
  if (is.null(aoi)) {
    return(.make_result(TRUE, aoi = NULL, crs = NULL))
  }

  # Normalize and validate user-provided CRS, if supplied
  if (!is.null(aoi_crs)) {

    crs_check <- normalize_crs(aoi_crs)

    if (!isTRUE(crs_check)) {
      return(crs_check)
    }

    # Extract normalized CRS string
    aoi_crs <- attr(crs_check, "crs")
  }

  # Extract CRS already attached to AOI
  object_crs <- terra::crs(aoi)

  # Check whether AOI already has CRS metadata
  has_object_crs <- nzchar(object_crs)

  # If object has no CRS and user did not provide one,
  # we cannot interpret coordinates safely
  if (!has_object_crs && is.null(aoi_crs)) {
    return(.make_result(
      FALSE,
      message = "`aoi` has no CRS. Supply `aoi_crs` or attach a CRS to `aoi`."
    ))
  }

  # Prevent conflicting CRS definitions:
  # user should not provide aoi_crs if object already has CRS
  if (has_object_crs && !is.null(aoi_crs)) {
    return(.make_result(
      FALSE,
      message = "`aoi` already has a CRS. Do not also provide `aoi_crs`."
    ))
  }

  # If AOI lacks CRS, assign the user-provided CRS
  if (!has_object_crs) {
    terra::crs(aoi) <- aoi_crs
    object_crs <- terra::crs(aoi)
  }

  .make_result(TRUE, aoi = aoi, crs = object_crs)
}