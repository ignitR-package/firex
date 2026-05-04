resolve_aoi <- function(aoi,
                        aoi_crs = NULL,
                        target_crs = "EPSG:4326") {

  coerced <- coerce_aoi(aoi)
  if (!isTRUE(coerced)) return(coerced)

  aoi_obj <- attr(coerced, "aoi")

  crs_resolved <- resolve_aoi_crs(aoi_obj, aoi_crs)
  if (!isTRUE(crs_resolved)) return(crs_resolved)

  aoi_obj <- attr(crs_resolved, "aoi")

  projected <- project_aoi(aoi_obj, target_crs)
  if (!isTRUE(projected)) return(projected)

  aoi_obj <- attr(projected, "aoi")

  bbox_result <- aoi_to_bbox(aoi_obj)
  if (!isTRUE(bbox_result)) return(bbox_result)

  .make_result(
    TRUE,
    aoi = aoi_obj,
    bbox = attr(bbox_result, "bbox"),
    crs = attr(bbox_result, "crs"),
    type = attr(coerced, "type")
  )
}