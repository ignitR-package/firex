#' Resolve an area of interest
#'
#' Converts supported area-of-interest inputs to a `terra` polygon, bounding
#' box, extent, and CRS.
#'
#' @param aoi Area of interest. Accepted inputs include `NULL`, a numeric vector
#'   `c(xmin, ymin, xmax, ymax)`, a character file path readable by
#'   `terra::vect()` or `terra::rast()`, or an object supported by
#'   `terra::ext()`.
#' @param aoi_crs Optional character or integer CRS specification for `aoi`,
#'   such as `"EPSG:4326"` or `4326`.
#'
#' @return A length-1 logical with result metadata stored in attributes,
#'   including `"aoi"`, `"bbox"`, `"extent"`, `"crs"`, `"type"`, and
#'   `"message"` when validation fails.
#' @keywords internal
resolve_aoi <- function(aoi, aoi_crs = NULL) {

  # Handle null aoi
  if (is.null(aoi)) {
    return(.make_result(TRUE, aoi = NULL, bbox = NULL, extent = NULL, crs = NULL))
  }

  # Handle file paths, try converting to vect/rast
  if (is.character(aoi) && length(aoi) == 1L && file.exists(aoi)) {
    path_obj <- tryCatch(
      terra::vect(aoi),
      error = function(e) NULL
    )

    if (is.null(path_obj)) {
      path_obj <- tryCatch(
        terra::rast(aoi),
        error = function(e) NULL
      )
    }

    if (is.null(path_obj)) {
      return(.make_result(
        FALSE,
        message = "`aoi` file path could not be read by terra::vect() or terra::rast()."
      ))
    }

    aoi <- path_obj
  }

  crs_result <- resolve_aoi_crs(aoi, aoi_crs)

  if (!isTRUE(crs_result)) {
    return(crs_result)
  }

  resolved_crs <- attr(crs_result, "crs")

  if (is.numeric(aoi)) {
    if (length(aoi) != 4L || anyNA(aoi) || any(!is.finite(aoi))) {
      return(.make_result(
        FALSE,
        message = "`aoi` must contain four numeric values: c(xmin, ymin, xmax, ymax)."
      ))
    }

    bbox_label <- paste0(
      "aoi = c(xmin = ", aoi[1],
      ", ymin = ", aoi[2],
      ", xmax = ", aoi[3],
      ", ymax = ", aoi[4],
      ")"
    )

    if (aoi[1] >= aoi[3]) {
      return(.make_result(
        FALSE,
        message = paste0("You supplied ", bbox_label, ". `xmin` must be less than `xmax`.")
      ))
    }

    if (aoi[2] >= aoi[4]) {
      return(.make_result(
        FALSE,
        message = paste0("You supplied ", bbox_label, ". `ymin` must be less than `ymax`.")
      ))
    }

    # User/package bbox order: c(xmin, ymin, xmax, ymax)
    # terra::ext() order: xmin, xmax, ymin, ymax
    extent <- terra::ext(
      aoi[1],
      aoi[3],
      aoi[2],
      aoi[4]
    )

    input_type <- "bbox"

  } else {
    extent <- tryCatch(
      terra::ext(aoi),
      error = function(e) NULL
    )

    input_type <- class(aoi)[1]
  }

  if (is.null(extent)) {
    return(.make_result(
      FALSE,
      message = "`aoi` is not in a supported format. Provide a numeric bbox, terra spatial object, or another object supported by terra::ext()."
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

  crs_assigned <- tryCatch(
    {
      terra::crs(aoi_poly) <- resolved_crs
      TRUE
    },
    error = function(e) FALSE
  )

  if (!isTRUE(crs_assigned)) {
    return(.make_result(
      FALSE,
      message = "`aoi_crs` is not recognized. Provide an EPSG code, PROJ string, or WKT string."
    ))
  }

  bbox <- c(
    xmin = unname(extent$xmin),
    ymin = unname(extent$ymin),
    xmax = unname(extent$xmax),
    ymax = unname(extent$ymax)
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
