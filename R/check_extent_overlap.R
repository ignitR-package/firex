#' Check whether a bounding box falls within a layer extent
#'
#' Checks whether a requested bounding box is fully contained within the
#' extent of a layer bounding box.
#'
#' @param bbox Numeric vector in the form \code{c(xmin, ymin, xmax, ymax)}
#'   in EPSG:4326.
#' @param layer_bbox Numeric vector in the form
#'   \code{c(xmin, ymin, xmax, ymax)} describing the layer extent in EPSG:4326.
#'
#' @return A length-1 logical. Returns \code{TRUE} when \code{bbox} is fully
#'   contained within the requested layer extent and \code{FALSE} otherwise.
#'   The return value carries \code{"status"}, \code{"message"}, and
#'   \code{"bbox"} attributes that can be inspected later.
#'
#' @details Overlap outcomes:
#' \itemize{
#' \item Full overlap - returns \code{TRUE}
#' \item Partial overlap - returns \code{FALSE} with a message describing
#'   which side of the layer extent the bbox exceeds
#' \item No overlap - returns \code{FALSE} with a message that the bbox does
#'   not overlap the layer extent
#' }
#'
#' @keywords internal
check_extent_overlap <- function(bbox, layer_bbox) {
  is_within_extent <- bbox[1] >= layer_bbox[1] &&
    bbox[2] >= layer_bbox[2] &&
    bbox[3] <= layer_bbox[3] &&
    bbox[4] <= layer_bbox[4]

  if (is_within_extent) {
    return(.make_result(TRUE, status = "inside", bbox = bbox))
  }

  has_overlap <- bbox[1] < layer_bbox[3] &&
    bbox[3] > layer_bbox[1] &&
    bbox[2] < layer_bbox[4] &&
    bbox[4] > layer_bbox[2]

  if (has_overlap) {
    outside_sides <- c(
      west = bbox[1] < layer_bbox[1],
      south = bbox[2] < layer_bbox[2],
      east = bbox[3] > layer_bbox[3],
      north = bbox[4] > layer_bbox[4]
    )

    side_labels <- c(
      west = "west",
      south = "south",
      east = "east",
      north = "north"
    )

    side_text <- paste(unname(side_labels[names(outside_sides)[outside_sides]]), collapse = ", ")

    return(.make_result(
      FALSE,
      message = paste0("Requested bbox extends outside the layer extent on the ", side_text, "."),
      status = "partial",
      bbox = bbox
    ))
  }

  .make_result(
    FALSE,
    message = "Requested bbox does not overlap the layer extent.",
    status = "none",
    bbox = bbox
  )
}
