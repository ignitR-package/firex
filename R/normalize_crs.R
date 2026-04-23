normalize_crs <- function(crs) {

    if (is.null(crs)) {
        # return true
        # crs = NULL
    }

    # Optional, maybe not necessary
    #if (inherits(crs, c("SpatVector", "SpatRaster", "SpatExtent"))) {
        # return TRUE
        # crs = terra
    #}

    if (is.numeric(crs)) {
        crs <- paste0("EPSG:", as.integer(crs))
    }

    if (is.character(crs) && nchar(crs) == 4 && grepl("^[0-9]+$", crs)) {
        crs <- paste0("EPSG:", crs)
    }

    validated <- tryCatch(
        terra::crs(crs, describe = TRUE)
        , error = function(e) NULL
    )

    if (is.null(validated)) {
        # return FALSE
        # message = ...
        #
    }

    .make_result(TRUE, crs = crs)
}