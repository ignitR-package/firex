#' Check if a bounding box is valid
#'
#' @param bbox numeric vector. Expected format: \code{c(xmin, ymin, xmax, ymax)}
#'   in EPSG:4326.
#'
#' @return \code{TRUE} if valid, \code{FALSE} with a warning otherwise.
#'
#' @examples
#' is_valid_bbox(c(-120, 34, -119, 35))  # TRUE
#' is_valid_bbox(c(-119, 34, -120, 35))  # FALSE
#'
#' @export
#'

is_valid_bbox <- function(bbox) {
  if (!is.numeric(bbox) || length(bbox) != 4L) {
    warning("`bbox` must be a length-4 numeric vector: c(xmin, ymin, xmax, ymax)", call. = FALSE)
    return(FALSE)
  }
  if (bbox[1] >= bbox[3]) {
    warning("`bbox` xmin must be less than xmax: c(xmin, ymin, xmax, ymax)", call. = FALSE)
    return(FALSE)
  }
  if (bbox[2] >= bbox[4]) {
    warning("`bbox` ymin must be less than ymax: c(xmin, ymin, xmax, ymax)", call. = FALSE)
    return(FALSE)
  }
  if (bbox[1] < -180 || bbox[3] > 180) {
    warning("`bbox` longitude (x) values must be between -180 and 180", call. = FALSE)
    return(FALSE)
  }
  if (bbox[2] < -90 || bbox[4] > 90) {
    warning("`bbox` latitude (y) values must be between -90 and 90", call. = FALSE)
    return(FALSE)
  }
  TRUE
}


