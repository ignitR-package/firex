resolve_aoi_crs <- function(aoi, aoi_crs = NULL) {

  if (!is.null(aoi_crs)) {

    if (is.numeric(aoi_crs)) {
      aoi_crs <- paste0("EPSG:", as.integer(aoi_crs))
    }

    if (is.character(aoi_crs) && length(aoi_crs) == 1L && grepl("^[0-9]+$", aoi_crs)) {
      aoi_crs <- paste0("EPSG:", aoi_crs)
    }

    crs_valid <- tryCatch(
      terra::crs(aoi_crs, describe = TRUE),
      error = function(e) NULL
    )

    if (is.null(crs_valid) || all(is.na(crs_valid))) {
      return(.make_result(
        FALSE,
        message = "`aoi_crs` is not recognized. Provide an EPSG code, PROJ string, or WKT string."
      ))
    }
  }

  #
  object_crs <- tryCatch(
    terra::crs(aoi),
    error = function(e) "" # If crs(aoi) errors,
  )

  # Sucessfully found CRS?
  has_object_crs <- nzchar(object_crs)

  if (has_object_crs && !is.null(aoi_crs)) {
    return(.make_result(
      FALSE,
      message = "`aoi` already has a CRS. Do not also supply `aoi_crs`."
    ))
  }

  if (has_object_crs) {
    return(.make_result(TRUE, crs = object_crs))
  }

  if (!is.null(aoi_crs)) {
    return(.make_result(TRUE, crs = aoi_crs))
  }

  .make_result(
    FALSE,
    message = "`aoi` has no CRS. Supply `aoi_crs` or attach a CRS to `aoi`."
  )
}
