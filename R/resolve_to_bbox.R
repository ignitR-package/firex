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
        # if aoi is SpatVect, SpatRast, or SpatExt, pass aoi as-is
        if (inherits(aoi, c("SpatVector", "SpatRaster", "SpatExtent"))) aoi
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

    # If object has crs and different crs provided
    if (has_crs && !is.null(aoi_crs)) {
        return(.make_result(
            FALSE,
            message = "`aoi` already has a CRS. Either remove `aoi_crs` or strip the CRS from `aoi`."
        ))
    }

    # If object has no crs and crs provided
    if (!has_crs) {
        # Assign crs w terra
        terra::crs(spat_obj) <- aoi_crs
    }

    # Attempt to extract extent
    extent <- terra::ext(spat_obj)

    # Check for 0 area
    if ((extent$xmin == extent$xmax && extent$ymin == extent$ymax) || is.empty(extent)) {
        return(.make_result(
            FALSE,
            message = "`aoi` is empty or a single point. Provide an object with area, multiple points, or a line."
        ))
    }

    bbox <- c(extent$xmin, extent$ymin, extent$xmax, extent$ymax)

    .make_result(TRUE, bbox = bbox, crs = terra::crs(spat_obj))

}
