# =============================================================================
# STAC Helper Functions (Internal) — devtools::load_all() workflow
#
# ASSUMPTIONS:
# - Dev workflow (not installed) is OK
# - STAC is link-navigable:
#     catalog.json -> rel="child" to collection.json
#     collection.json -> rel="item" to items/*.json
# =============================================================================
wri_items_df <- function(data) {

  if (is.null(data$items) || length(data$items) == 0) {
    return(data.frame())
  }

  out <- lapply(seq_along(data$items), function(i) {

    item_wrapper <- data$items[[i]]
    item_obj <- item_wrapper$item
    bbox <- item_obj$bbox

    if (is.null(bbox) || length(bbox) != 4) {
      xmin <- ymin <- xmax <- ymax <- NA_real_
    } else {
      xmin <- as.numeric(bbox[1])
      ymin <- as.numeric(bbox[2])
      xmax <- as.numeric(bbox[3])
      ymax <- as.numeric(bbox[4])
    }

    assets <- item_wrapper$assets

    if (is.null(assets) || nrow(assets) == 0) {
      return(data.frame(
        stac_index = i,
        item_order_in_collection = item_wrapper$item_order_in_collection %||% NA_integer_,
        id = item_wrapper$id,
        collection = item_wrapper$collection,
        item_path = item_wrapper$item_path,
        asset_name = NA_character_,
        asset_href = NA_character_,
        asset_type = NA_character_,
        datetime = .wri_prop1(item_obj, "datetime"),
        proj_code = .wri_prop1(item_obj, "proj:code"),
        data_type = .wri_prop1(item_obj, "data_type"),
        wri_domain = .wri_prop1(item_obj, "wri_domain"),
        wri_dimension = .wri_prop1(item_obj, "wri_dimension"),
        is_hosted = .wri_prop1(item_obj, "is_hosted"),
        xmin = xmin,
        ymin = ymin,
        xmax = xmax,
        ymax = ymax,
        stringsAsFactors = FALSE
      ))
    }

    data.frame(
      stac_index = i,
      item_order_in_collection = item_wrapper$item_order_in_collection %||% NA_integer_,
      id = item_wrapper$id,
      collection = item_wrapper$collection,
      item_path = item_wrapper$item_path,
      asset_name = assets$asset_name,
      asset_href = assets$href,
      asset_type = assets$type,
      datetime = .wri_prop1(item_obj, "datetime"),
      proj_code = .wri_prop1(item_obj, "proj:code"),
      data_type = .wri_prop1(item_obj, "data_type"),
      wri_domain = .wri_prop1(item_obj, "wri_domain"),
      wri_dimension = .wri_prop1(item_obj, "wri_dimension"),
      is_hosted = .wri_prop1(item_obj, "is_hosted"),
      xmin = xmin,
      ymin = ymin,
      xmax = xmax,
      ymax = ymax,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, out)
}
