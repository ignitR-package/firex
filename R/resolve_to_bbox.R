#' Resolve an area-of-interest to a bounding box
#'
#' Accepts an area of interest in several common formats and returns its
#' axis-aligned bounding box as a numeric vector \code{c(xmin, ymin, xmax,
#' ymax)} in the input CRS.
#'
#' @param aoi Area of interest. Accepted inputs:
#'   \itemize{
#'     \item Numeric vector \code{c(xmin, ymin, xmax, ymax)} — bounding box;
#'       \code{aoi_crs} is required.
#'     \item Character path to a shapefile (\code{.shp}) or GeoJSON file.
#'     \item An \code{sf} or \code{sfc} object.
#'     \item A \code{terra::SpatVector}, \code{terra::SpatRaster}, or
#'       \code{terra::SpatExtent}.
#'   }
#' @param aoi_crs Character or integer CRS specification (e.g.
#'   \code{"EPSG:4326"} or \code{4326}). Required when \code{aoi} is a
#'   numeric vector or a CRS-less spatial object; must be omitted when
#'   \code{aoi} already carries a CRS.
#'
#' @return A length-1 logical. On success (\code{TRUE}) carries \code{"bbox"}
#'   (numeric \code{c(xmin, ymin, xmax, ymax)}) and \code{"crs"} attributes.
#'   On failure (\code{FALSE}) carries a \code{"message"} attribute describing
#'   the problem.
#'
#' @keywords internal
#'
#' @examples
#' result <- resolve_to_bbox(c(-122, 37, -121, 38), aoi_crs = "EPSG:4326")
#' isTRUE(result)        # TRUE
#' attr(result, "bbox")  # c(-122, 37, -121, 38)
#' attr(result, "crs")   # "EPSG:4326"
resolve_to_bbox <- function(aoi, aoi_crs = NULL) {

    # Check if input numeric vect len 4
    if (is.numeric(aoi) && length(aoi) == 4) {

        # Message if no crs given
        if (is.null(aoi_crs)) {
            return(.make_result(
                FALSE,
                message = "Numeric bbox requires `aoi_crs` to be specified"
                ))
        }

        return(.make_result(
            TRUE,
            bbox = aoi,
            crs = aoi_crs
        ))
    }

    # Coerce to terra
    spat_obj <- tryCatch({
        if (inherits(aoi, c("SpatVector", "SpatRaster"))) aoi

        # SpatExtent is a bbox struct, not a geometry feature so terra::vect() and crs assignment
        # don't work on it directly, as.polygons() converts it to a spatial object
        else if (inherits(aoi, "SpatExtent")) terra::as.polygons(aoi)
        else terra::vect(aoi)
    }, error = function(e) NULL)

    if (is.null(spat_obj)) {
        return(.make_result(
            FALSE,
            message = paste0(
                "`aoi` could not be coerced to a spatial object. ",
                "Accepted types: numeric bbox, SpatVector, SpatRaster, SpatExtent, ",
                "sf object, shapefile path, GeoJSON path, or WKT string."
            )
        ))
    }

    # Check if object has crs
    has_crs <- nzchar(terra::crs(spat_obj))

    # If object does not have crs and no crs provided
    if (!has_crs && is.null(aoi_crs)) {
        return(.make_result(
            FALSE,
            message = "`aoi` has no CRS. Supply `aoi_crs` or attach a CRS to `aoi`."
        ))
    }

    # If object has a CRS and a conflicting CRS was also provided
    if (has_crs && !is.null(aoi_crs)) {
        object_crs <- terra::crs(spat_obj)

        if (!terra::same.crs(object_crs, aoi_crs)) {
            return(.make_result(
                FALSE,
                message = paste0(
                    "`aoi` already has CRS '", object_crs, "'. ",
                    "It does not match `aoi_crs = ", aoi_crs, "`. ",
                    "Remove `aoi_crs` or supply a matching CRS."
                )
            ))
        }
    }

    # If object has no crs and crs provided
    if (!has_crs) {
        terra::crs(spat_obj) <- aoi_crs
    }

    # Attempt to extract extent
    extent <- terra::ext(spat_obj)

    # Change to spat obj with crs

    # Check for 0 area
    if ((extent$xmin == extent$xmax && extent$ymin == extent$ymax) || terra::is.empty(extent)) {
        return(.make_result(
            FALSE,
            message = "`aoi` is empty or a single point. Provide an object with area, multiple points, or a line."
        ))
    }

    bbox <- c(extent$xmin, extent$ymin, extent$xmax, extent$ymax)

    .make_result(TRUE, bbox = bbox, crs = terra::crs(spat_obj))

}
