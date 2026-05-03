#' Check if a bounding box is valid
#'
#' @param bbox numeric vector. Expected format: \code{c(xmin, ymin, xmax, ymax)}
#'   in the supplied \code{crs}.
#' @param crs character. Coordinate reference system of the bounding box.
#'   Default is \code{"EPSG:4326"}.
#'
#' @return A length-1 logical with \code{"status"}, \code{"message"}, and
#'   \code{"bbox"} attributes. On success, the \code{"bbox"} attribute contains
#'   the validated bounding box in EPSG:4326.
#'
#' @examples
#' is_valid_bbox(c(-120, 34, -119, 35))  # TRUE
#' is_valid_bbox(c(-119, 34, -120, 35))  # FALSE
#'
#' @export
#'
is_valid_bbox <- function(bbox, crs = "EPSG:4326") {

  format_bbox <- function(x) {
    paste0(
      "You supplied bbox = c(",
      "xmin = ", x[1], ", ",
      "ymin = ", x[2], ", ",
      "xmax = ", x[3], ", ",
      "ymax = ", x[4], "). "
    )
  }

  # Validate basic bbox format and value types
  if (!is.numeric(bbox) || length(bbox) != 4L) {
    return(.make_result(
      FALSE,
      message = paste(
        "`bbox` must contain four numeric values:",
        "c(xmin, ymin, xmax, ymax)."
      ),
      status = "invalid"
    ))
  }

  original_bbox <- bbox
  was_reprojected <- !identical(toupper(crs), "EPSG:4326")

  # If the CRS is not EPSG:4326, reproject to EPSG:4326 for validation
  if (was_reprojected) {
    bbox_poly <- tryCatch(
      terra::as.polygons(
        terra::ext(bbox[1], bbox[3], bbox[2], bbox[4]),
        crs = crs
      ),
      error = function(e) NULL
    )

    if (is.null(bbox_poly)) {
      return(.make_result(
        FALSE,
        message = paste0("Could not interpret bbox with CRS '", crs, "'."),
        status = "invalid"
      ))
    }

    bbox_poly <- tryCatch(
      terra::project(bbox_poly, "EPSG:4326"),
      error = function(e) NULL
    )

    if (is.null(bbox_poly)) {
      return(.make_result(
        FALSE,
        message = paste0("Could not transform bbox from '", crs, "' to 'EPSG:4326'."),
        status = "invalid"
      ))
    }

    bbox_ext <- terra::ext(bbox_poly)
    bbox <- c(bbox_ext$xmin, bbox_ext$ymin, bbox_ext$xmax, bbox_ext$ymax)
  }

  xmin <- bbox[1]
  ymin <- bbox[2]
  xmax <- bbox[3]
  ymax <- bbox[4]
  bbox_label <- format_bbox(bbox)

  # When a non-WGS84 bbox was reprojected, append a note so the user knows the
  # values shown are WGS84 and what their original input was
  reproject_note <- if (was_reprojected) {
    paste0(
      "(These are your coordinates reprojected to WGS84 from '", crs, "'. ",
      "Your original values were c(",
      "xmin = ", original_bbox[1], ", ",
      "ymin = ", original_bbox[2], ", ",
      "xmax = ", original_bbox[3], ", ",
      "ymax = ", original_bbox[4], ").)"
    )
  } else ""

  if (xmin >= xmax) {
    return(.make_result(
      FALSE,
      paste0(bbox_label, "`xmin` must be less than `xmax`. ", reproject_note),
      "invalid",
      bbox
    ))
  }

  if (ymin >= ymax) {
    return(.make_result(
      FALSE,
      paste0(bbox_label, "`ymin` must be less than `ymax`. ", reproject_note),
      "invalid",
      bbox
    ))
  }

  if (xmin < -180 || xmax > 180) {
    return(.make_result(
      FALSE,
      paste0(
        bbox_label,
        "`xmin` and `xmax` must be between -180 and 180. ",
        reproject_note
      ),
      "invalid",
      bbox
    ))
  }

  if (ymin < -90 || ymax > 90) {
    return(.make_result(
      FALSE,
      paste0(
        bbox_label,
        "`ymin` and `ymax` must be between -90 and 90. ",
        reproject_note
      ),
      "invalid",
      bbox
    ))
  }

  .make_result(TRUE, status = "valid", bbox = bbox)
}
