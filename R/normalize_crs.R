#' Normalize a CRS specification
#'
#' Validates a coordinate reference system supplied in any of the common
#' shorthand formats and returns a canonicalized string that \code{terra}
#' recognizes. Useful for checking a CRS value before passing it to
#' \code{\link{get_layer}} or \code{\link{resolve_to_bbox}}.
#'
#' @param crs One of:
#'   \itemize{
#'     \item An integer EPSG code (e.g. \code{4326}).
#'     \item A character string: \code{"EPSG:4326"}, a bare numeric string
#'       (\code{"4326"}), a PROJ string, or a WKT string.
#'     \item \code{NULL} — treated as "no CRS" and returns \code{TRUE}
#'       with no \code{"crs"} attribute.
#'   }
#'
#' @return A length-1 logical. On success (\code{TRUE}) carries a \code{"crs"}
#'   attribute containing the normalized CRS string. On failure (\code{FALSE})
#'   carries a \code{"message"} attribute describing why the input was not
#'   recognized.
#'
#' @examples
#' r <- normalize_crs(4326)
#' isTRUE(r)          # TRUE
#' attr(r, "crs")     # "EPSG:4326"
#'
#' r2 <- normalize_crs("32611")
#' attr(r2, "crs")    # "EPSG:32611"
#'
#' r_bad <- normalize_crs("not-a-crs")
#' isTRUE(r_bad)      # FALSE
#' attr(r_bad, "message")
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