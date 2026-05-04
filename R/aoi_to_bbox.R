# Extract bbox/extents from an AOI
aoi_to_bbox <- function(aoi) {

  # NULL AOI means no cropping/global layer
  if (is.null(aoi)) {
    return(.make_result(TRUE, bbox = NULL, crs = NULL))
  }

  # Check whether geometry is empty
  if (terra::is.empty(aoi)) {
    return(.make_result(
      FALSE,
      message = "`aoi` is empty and has no usable extent."
    ))
  }

  # Extract spatial extent from AOI
  ext <- tryCatch(
    terra::ext(aoi),
    error = function(e) NULL
  )

  if (is.null(ext)) {
    return(.make_result(
      FALSE,
      message = "Could not extract extent from `aoi`."
    ))
  }

  # Ensure bbox values are valid numerics
  if (
    is.na(ext$xmin) || is.na(ext$xmax) ||
    is.na(ext$ymin) || is.na(ext$ymax)
  ) {
    return(.make_result(
      FALSE,
      message = "`aoi` extent contains missing values."
    ))
  }

  # Reject zero-area extents
  # Single points produce:
  # xmin == xmax
  # ymin == ymax
  if (ext$xmin >= ext$xmax || ext$ymin >= ext$ymax) {
    return(.make_result(
      FALSE,
      message = paste(
        "`aoi` has zero-area extent.",
        "Single points are not valid AOIs unless buffered."
      )
    ))
  }

  # Return bbox in standard order:
  # xmin, ymin, xmax, ymax
  bbox <- c(
    xmin = ext$xmin,
    ymin = ext$ymin,
    xmax = ext$xmax,
    ymax = ext$ymax
  )

  .make_result(TRUE, bbox = bbox, crs = terra::crs(aoi))
}