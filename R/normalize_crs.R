#' Normalize a CRS specification
#' 
#' Accepts CRS in several common formats and returns a terra recognized form.
#' 
#' @param crs One of the following formats: an integer EPSG code (e.g. \code{4326}), a character string... 
#' [COMPLETE DESCRIPTION OF ACCEPTED CRS FORMATS]
#' 
#' @return A length-1 logical with \code{"status"}, \code{"message"}, and
#'   \code{"bbox"} attributes. On success, the \code{"crs"} attribute contains
#'   the validated CRS string.
#' 
#' 
#' @keywords internal
normalize_crs <- function(crs) {

    if (is.null(crs)) {
        return(.make_result(TRUE))
    }

    # Optional, maybe not necessary
    #if (inherits(crs, c("SpatVector", "SpatRaster", "SpatExtent"))) {
    #    crs <- terra::crs(crs)
    #}

    if (is.numeric(crs)) {
        crs <- paste0("EPSG:", as.integer(crs))
    }

    if (is.character(crs) && length(crs) == 1 && grepl("^[0-9]+$", crs)) {
        crs <- paste0("EPSG:", crs)
    }

    validated <- tryCatch(
        terra::crs(crs, describe = TRUE), 
        error = function(e) NULL
    )

    if (is.null(validated) || all(is.na(validated))) {
        return(.make_result(
            FALSE,
            message = '`crs` value not recognized. Provide an EPSG code (e.g. 4326 or "EPSG:4326"), a PROJ string, a WKT string, or a spatial object with a crs.'
        ))
    }

    .make_result(TRUE, crs = crs)
}