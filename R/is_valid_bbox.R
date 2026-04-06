#' Check if a bounding box is valid
#'
#' Tests whether a bounding box vector meets all validation criteria.
#' This is an internal helper function used by \code{get_tif()}.
#'
#' @param bbox numeric vector. Expected format: \code{c(xmin, ymin, xmax, ymax)}
#'   in EPSG:4326.
#'
#' @return Logical. \code{TRUE} if the bounding box is valid, \code{FALSE} otherwise.
#'
#' @details Validation checks:
#'   \itemize{
#'     \item Must be numeric
#'     \item Must be length 4
#'     \item \code{xmin} must be less than \code{xmax}
#'     \item \code{ymin} must be less than \code{ymax}
#'     \item Longitude values must be between -180 and 180
#'     \item Latitude values must be between -90 and 90
#'   }
#'
#' @keywords internal
#' @seealso Used by: \code{get_tif()}
#'
#' @examples
#' \dontrun{
#' is_valid_bbox(c(-120, 30, -100, 50))  # TRUE
#' is_valid_bbox(c(-100, 30, -120, 50))  # FALSE - xmin > xmax
#' }
is_valid_bbox <- function(bbox) {
  # Check if numeric
  if (!is.numeric(bbox)) return(FALSE)

  # Check if length 4
  if (length(bbox) != 4) return(FALSE)

  xmin <- bbox[1]
  ymin <- bbox[2]
  xmax <- bbox[3]
  ymax <- bbox[4]

  # Check coordinate ordering
  if (xmin >= xmax || ymin >= ymax) return(FALSE)

  # Check longitude range (-180 to 180)
  if (xmin < -180 || xmax > 180) return(FALSE)

  # Check latitude range (-90 to 90)
  if (ymin < -90 || ymax > 90) return(FALSE)

  return(TRUE)
}
