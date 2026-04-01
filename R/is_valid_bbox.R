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
    if (!is.numeric(bbox) || length(bbox) != 4L) {
        return(paste0("`bbox` must be a length-4 numeric vector: c(xmin, ymin, xmax, ymax). Check your input.", call. = FALSE))
    }
    if (bbox[1] >= bbox[3]) {
        return(paste0("`bbox` xmin must be less than xmax: c(xmin, ymin, xmax, ymax). Check your input. Are you using the correct CRS?", call. = FALSE))
    }
    if (bbox[2] >= bbox[4]) {
        return(paste0("`bbox` ymin must be less than ymax: c(xmin, ymin, xmax, ymax). Check your input. Are you using the correct CRS?", call. = FALSE))
    }
    if (bbox[1] < -180 || bbox[3] > 180) {
        return(paste0("`bbox` longitude (x) values must be between -180 and 180. Check your input. Are you using the correct CRS?", call. = FALSE))
    }
    if (bbox[2] < -90 || bbox[4] > 90) {
        return(paste0("`bbox` latitude (y) values must be between -90 and 90. Check your input. Are you using the correct CRS?", call. = FALSE))
    }
    return(TRUE)
}