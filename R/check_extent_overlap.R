#' Check overlap between a region and WRI layer extent
#'
#' Checks whether a region of interest falls within the extent of the
#' requested WRI layers. If the region partially or fully falls outside,
#' stops or warns with a description of how much of the region is out of
#' bounds.
#'
#' @param region sf. The region of interest as an \code{sf} polygon in
#' EPSG:4326. Should already be validated and normalized before passing.
#' @param layer_id character. One or more layer IDs to check extent against.
#'
#' @return Invisibly returns \code{region} if fully within extent. Warns or
#' stops otherwise.
#'
#' @details Overlap outcomes:
#' \itemize{
#' \item Full overlap — passes silently
#' \item Partial overlap — warns with the percentage of the region
#' that falls outside the layer extent, then proceeds with the
#' intersecting portion
#' \item No overlap — stops with the distance to the nearest edge of
#' the layer extent, so the user knows how far off they are
#' }
#'
#' @Keywords internal
check_extent_overlap <- function(region, layer_id) {

    # if bbox, validate bounding box with validate_bbox()
    if (!is.null(bbox)) {
        check <- is_valid_bbox(bbox)
        # isTRUE() returns true only for TRUE values and false otherwise
        if (!isTRUE(check)) return(paste0(("Invalid bounding box: ", check))
    }

    # Find layer extent from STAC
    stac_file <- system.file(
        "extdata/stac/collections/wri_ignitR/items",
        paste0(layer_id, ".json"),
        package = "firex"
    )

    # Return error message if layer not found in STAC
    if (stac_file == "") return(paste0("Layer '", layer_id, "' not found."))
    
    # Layer extent in EPSG:4326 format: c(xmin, ymin, xmax, ymax)
    ext <- jsonlite::read_json(stac_file)$bbox

    # Check if bbox matches layer extent
    x_overlap <- region[1] < ext[[3]] && bbox[3] > ext[[1]]
    y_overlap <- region[2] < ext[[4]] && bbox[4] > ext[[2]]

    if (!x_overlap || !y_overlap) {
        return(paste0("Region is not contained within the extent of layer '", layer_id, "'."))
    }

    return(TRUE)

}
