# Project AOI into a target CRS
project_aoi <- function(aoi, target_crs = "EPSG:4326") {

  # NULL AOI means no cropping/global layer
  if (is.null(aoi)) {
    return(.make_result(TRUE, aoi = NULL, crs = NULL))
  }

  # Validate target CRS
  target_check <- normalize_crs(target_crs)

  if (!isTRUE(target_check)) {
    return(target_check)
  }

  target_crs <- attr(target_check, "crs")

  # Extract current AOI CRS
  current_crs <- terra::crs(aoi)

  # Projection requires a known CRS
  if (!nzchar(current_crs)) {
    return(.make_result(
      FALSE,
      message = "`aoi` must have a CRS before it can be projected."
    ))
  }

  # If AOI already in target CRS,
  # avoid unnecessary reprojection
  same_crs <- tryCatch(
    terra::same.crs(current_crs, target_crs),
    error = function(e) FALSE
  )

  if (isTRUE(same_crs)) {
    return(.make_result(TRUE, aoi = aoi, crs = current_crs))
  }

  # Reproject AOI geometry into target CRS
  # This CHANGES coordinate values
  projected <- tryCatch(
    terra::project(aoi, target_crs),
    error = function(e) NULL
  )

  if (is.null(projected)) {
    return(.make_result(
      FALSE,
      message = paste0(
        "Could not project `aoi` from its CRS to target CRS '",
        target_crs,
        "'."
      )
    ))
  }

  .make_result(TRUE, aoi = projected, crs = terra::crs(projected))
}